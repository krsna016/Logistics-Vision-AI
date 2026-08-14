import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/storage/local_data_archive_service.dart';

void main() {
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

  test('archives database and every local document with an inventory',
      () async {
    final archiveFile = await LocalDataArchiveService(
      database,
      documentsDirectory: () async => documents,
    ).createArchive();

    final archive = ZipDecoder().decodeBytes(await archiveFile.readAsBytes());
    expect(archive.findFile('database/smartload_offline.sqlite'), isNotNull);
    expect(archive.findFile('documents/smartload_images/layer.jpg'), isNotNull);
    expect(
      archive.findFile('documents/backups/backup_manual.sqlite.bak'),
      isNotNull,
    );

    final manifest = archive.findFile('MANIFEST.json');
    expect(manifest, isNotNull);
    final data = jsonDecode(utf8.decode(manifest!.content as List<int>));
    expect(data['database'], 'database/smartload_offline.sqlite');
    final archivedPaths = (data['files'] as List<dynamic>)
        .map((entry) => (entry as Map<String, dynamic>)['path'])
        .toSet();
    expect(
      archivedPaths,
      containsAll(<String>{
        'database/smartload_offline.sqlite',
        'documents/smartload_images/layer.jpg',
        'documents/backups/backup_manual.sqlite.bak',
      }),
    );
  });

  test('imports a ZIP and restores operational rows and document files',
      () async {
    await seedLayerWithMasks();
    final service = LocalDataArchiveService(
      database,
      documentsDirectory: () async => documents,
    );
    final archiveFile = await service.createArchive();
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

    final summary = await service.importArchive(portableArchive);

    expect(summary.importedTables, greaterThanOrEqualTo(9));
    expect(summary.copiedFiles, greaterThan(0));
    expect(await database.select(database.warehouses).get(), hasLength(1));
    expect(
      await File('${documents.path}/smartload_images/layer.jpg').readAsString(),
      'image evidence',
    );
    await expectLayerMasksRestored();
  });

  test('imports a selected wrapper folder containing an extracted archive',
      () async {
    await seedLayerWithMasks();
    final service = LocalDataArchiveService(
      database,
      documentsDirectory: () async => documents,
    );
    final archiveFile = await service.createArchive();
    final selectedFolder =
        await Directory.systemTemp.createTemp('smartload_selected_folder_');
    addTearDown(() async {
      if (await selectedFolder.exists()) {
        await selectedFolder.delete(recursive: true);
      }
    });
    final archiveRoot =
        await Directory('${selectedFolder.path}/SmartLoad archive')
            .create(recursive: true);
    final archive = ZipDecoder().decodeBytes(await archiveFile.readAsBytes());
    for (final entry in archive) {
      if (!entry.isFile) continue;
      final output = File('${archiveRoot.path}/${entry.name}');
      await output.parent.create(recursive: true);
      await output.writeAsBytes(entry.content as List<int>);
    }

    await database.delete(database.warehouses).go();
    await (database.update(database.layers)
          ..where((layer) => layer.id.equals('layer-with-masks')))
        .write(const LayersCompanion(detectionsJson: Value('[]')));
    final summary = await service.importFolder(selectedFolder);

    expect(summary.importedTables, greaterThanOrEqualTo(9));
    expect(await database.select(database.warehouses).get(), hasLength(1));
    await expectLayerMasksRestored();
  });

  test('imports a ZIP that contains an outer wrapper folder', () async {
    final service = LocalDataArchiveService(
      database,
      documentsDirectory: () async => documents,
    );
    final originalArchive = await service.createArchive();
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
    final summary = await service.importArchive(wrappedZip);

    expect(summary.importedTables, greaterThanOrEqualTo(9));
    expect(await database.select(database.warehouses).get(), hasLength(1));
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
