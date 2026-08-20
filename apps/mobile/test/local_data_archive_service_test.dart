import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/storage/local_data_archive_service.dart';

void main() {
  const backupPassword = 'Safe backup password 2026';
  late Directory documents;
  late AppDatabase database;

  setUp(() async {
    documents =
        await Directory.systemTemp.createTemp('smartload_archive_test_');
    database = AppDatabase.forTesting(
      NativeDatabase(File('${documents.path}/smartload_offline.sqlite')),
    );
    await database.into(database.warehouses).insert(
          WarehousesCompanion.insert(
            id: 'warehouse-1',
            name: 'Audit warehouse',
            location: 'Test location',
          ),
        );
    await File('${documents.path}/smartload_images/layer.jpg')
        .create(recursive: true);
    await File('${documents.path}/smartload_images/layer.jpg')
        .writeAsString('image evidence');
    await File('${documents.path}/backups/backup_manual.sqlite.bak')
        .create(recursive: true);
    await File('${documents.path}/backups/backup_manual.sqlite.bak')
        .writeAsString('backup evidence');
  });

  tearDown(() async {
    await database.close();
    await documents.delete(recursive: true);
  });

  Future<void> seedLayerWithMasks() async {
    await database.into(database.trucks).insert(
          TrucksCompanion.insert(
            id: 'truck-with-masks',
            truckNumber: 'TRUCK-1',
            vehicleNumber: 'AS01AB1234',
            driverName: 'Driver',
            company: 'Carrier',
            status: 'loading',
          ),
        );
    await database.into(database.layers).insert(
          LayersCompanion.insert(
            id: 'layer-with-masks',
            truckId: 'truck-with-masks',
            layerNumber: 1,
            cartonCount: 1,
            detectionsJson: const Value(
              '[{"id":"carton-1","boundingBox":{"xMin":0.1,"yMin":0.2,"xMax":0.6,"yMax":0.8},"label":"carton","confidence":0.95,"polygon":[[0.1,0.2],[0.6,0.2],[0.6,0.8],[0.1,0.8]],"metadata":{}}]',
            ),
          ),
        );
  }

  Future<void> expectLayerMasksRestored() async {
    final restored = await (database.select(database.layers)
          ..where((layer) => layer.id.equals('layer-with-masks')))
        .getSingle();
    final detections = jsonDecode(restored.detectionsJson) as List<dynamic>;
    final polygon =
        (detections.single as Map<String, dynamic>)['polygon'] as List<dynamic>;
    expect(polygon, hasLength(4));
    expect(polygon.first, [0.1, 0.2]);
    expect(polygon.last, [0.1, 0.8]);
  }

  Future<File> createLegacyArchive() async {
    await database.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
    final legacy = File('${documents.parent.path}/legacy_smartload_backup.zip');
    final files = <(File, String)>[
      (
        File('${documents.path}/smartload_offline.sqlite'),
        'database/smartload_offline.sqlite',
      ),
      (
        File('${documents.path}/smartload_images/layer.jpg'),
        'documents/smartload_images/layer.jpg',
      ),
    ];
    final inventory = <Map<String, Object>>[];
    final encoder = ZipFileEncoder();
    encoder.create(legacy.path);
    for (final entry in files) {
      final file = entry.$1;
      final path = entry.$2;
      await encoder.addFile(file, path);
      inventory.add({
        'path': path,
        'sizeBytes': await file.length(),
        'sha256': (await sha256.bind(file.openRead()).first).toString(),
      });
    }
    encoder.addArchiveFile(ArchiveFile.string(
      'MANIFEST.json',
      jsonEncode({
        'format': 'SmartLoad local audit archive',
        'formatVersion': 2,
        'database': 'database/smartload_offline.sqlite',
        'files': inventory,
      }),
    ));
    await encoder.close();
    return legacy;
  }

  test('archives database and every local document with an inventory',
      () async {
    final archiveFile = await LocalDataArchiveService(
      database,
      documentsDirectory: () async => documents,
    ).createArchive(password: backupPassword);

    final archive = ZipDecoder().decodeBytes(await archiveFile.readAsBytes());
    expect(archive.findFile('database/smartload_offline.sqlite'), isNull);
    expect(archive.findFile('documents/smartload_images/layer.jpg'), isNull);
    expect(archive.findFile('backup_payload.bin'), isNotNull);
    final info = archive.findFile('BACKUP_INFO.json');
    expect(info, isNotNull);
    final data = jsonDecode(utf8.decode(info!.content as List<int>));
    expect(data['encryption'], 'AES-256-GCM');
    expect(data['kdf'], 'PBKDF2-HMAC-SHA256');
  });

  test('imports a ZIP and restores operational rows and document files',
      () async {
    await seedLayerWithMasks();
    final service = LocalDataArchiveService(
      database,
      documentsDirectory: () async => documents,
    );
    final archiveFile = await service.createArchive(password: backupPassword);
    final portableArchive = File('${documents.parent.path}/portable_audit.zip');
    await archiveFile.copy(portableArchive.path);
    addTearDown(() async {
      if (await portableArchive.exists()) await portableArchive.delete();
    });

    await database.delete(database.warehouses).go();
    await (database.update(database.layers)
          ..where((layer) => layer.id.equals('layer-with-masks')))
        .write(const LayersCompanion(detectionsJson: Value('[]')));
    await File('${documents.path}/smartload_images/layer.jpg')
        .writeAsString('changed after export');

    final summary = await service.importArchive(
      portableArchive,
      password: backupPassword,
    );

    expect(summary.importedTables, greaterThanOrEqualTo(9));
    expect(summary.copiedFiles, greaterThan(0));
    expect(await database.select(database.warehouses).get(), hasLength(1));
    expect(
      await File('${documents.path}/smartload_images/layer.jpg').readAsString(),
      'image evidence',
    );
    await expectLayerMasksRestored();
  });

  test('imports a legacy unprotected SmartLoad ZIP without a password',
      () async {
    final service = LocalDataArchiveService(
      database,
      documentsDirectory: () async => documents,
    );
    final legacyArchive = await createLegacyArchive();
    addTearDown(() async {
      if (await legacyArchive.exists()) await legacyArchive.delete();
    });

    await database.delete(database.warehouses).go();
    await File('${documents.path}/smartload_images/layer.jpg')
        .writeAsString('changed after export');

    final summary = await service.importArchive(legacyArchive);

    expect(summary.importedTables, greaterThanOrEqualTo(9));
    expect(await database.select(database.warehouses).get(), hasLength(1));
    expect(
      await File('${documents.path}/smartload_images/layer.jpg').readAsString(),
      'image evidence',
    );
  });

  test('rejects an incorrect backup password without importing data', () async {
    await seedLayerWithMasks();
    final service = LocalDataArchiveService(
      database,
      documentsDirectory: () async => documents,
    );
    final archiveFile = await service.createArchive(password: backupPassword);

    await database.delete(database.warehouses).go();
    await (database.update(database.layers)
          ..where((layer) => layer.id.equals('layer-with-masks')))
        .write(const LayersCompanion(detectionsJson: Value('[]')));
    await expectLater(
      () => service.importArchive(archiveFile, password: 'Wrong password 2026'),
      throwsA(isA<StateError>()),
    );
    expect(await database.select(database.warehouses).get(), isEmpty);
  });

  test('rejects a ZIP wrapper that does not preserve the protected format',
      () async {
    final service = LocalDataArchiveService(
      database,
      documentsDirectory: () async => documents,
    );
    final originalArchive =
        await service.createArchive(password: backupPassword);
    final wrapper =
        await Directory.systemTemp.createTemp('smartload_zip_wrapper_');
    final archiveRoot = await Directory('${wrapper.path}/Shared backup')
        .create(recursive: true);
    final wrappedZip = File('${wrapper.parent.path}/wrapped_audit.zip');
    addTearDown(() async {
      if (await wrapper.exists()) await wrapper.delete(recursive: true);
      if (await wrappedZip.exists()) await wrappedZip.delete();
    });
    final archive =
        ZipDecoder().decodeBytes(await originalArchive.readAsBytes());
    for (final entry in archive) {
      if (!entry.isFile) continue;
      final output = File('${archiveRoot.path}/${entry.name}');
      await output.parent.create(recursive: true);
      await output.writeAsBytes(entry.content as List<int>);
    }
    final encoder = ZipFileEncoder();
    encoder.create(wrappedZip.path);
    await encoder.addDirectory(wrapper, includeDirName: true);
    await encoder.close();

    await database.delete(database.warehouses).go();
    await expectLater(
      () => service.importArchive(wrappedZip, password: backupPassword),
      throwsA(isA<StateError>()),
    );
    expect(await database.select(database.warehouses).get(), isEmpty);
  });

  test('lists automatic safety backups newest first', () async {
    final backupDir =
        await Directory('${documents.path}/backups').create(recursive: true);
    final older = await File('${backupDir.path}/pre_import_older.sqlite')
        .writeAsString('older');
    final newer = await File('${backupDir.path}/pre_restore_newer.sqlite')
        .writeAsString('newer');
    await older.setLastModified(DateTime(2026, 1, 1));
    await newer.setLastModified(DateTime(2026, 1, 2));

    final backups = await LocalDataArchiveService(
      database,
      documentsDirectory: () async => documents,
    ).listLocalBackups();

    expect(backups.map((backup) => backup.file.path), [newer.path, older.path]);
  });

  test('restores an automatic database backup and protects current data',
      () async {
    final service = LocalDataArchiveService(
      database,
      documentsDirectory: () async => documents,
    );
    await database.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
    final backupDir =
        await Directory('${documents.path}/backups').create(recursive: true);
    final oldSnapshot = File('${backupDir.path}/pre_import_original.sqlite');
    await File('${documents.path}/smartload_offline.sqlite')
        .copy(oldSnapshot.path);

    await database.delete(database.warehouses).go();
    await database.into(database.warehouses).insert(
          WarehousesCompanion.insert(
            id: 'warehouse-current',
            name: 'Current warehouse',
            location: 'Current location',
          ),
        );

    final selected = (await service.listLocalBackups())
        .firstWhere((backup) => backup.file.path == oldSnapshot.path);
    await service.restoreLocalBackup(selected);

    final restored = await database.select(database.warehouses).get();
    expect(restored.map((row) => row.id), ['warehouse-1']);
    expect(
      (await service.listLocalBackups())
          .any((backup) => backup.file.path.contains('pre_restore_')),
      isTrue,
    );
  });
}
