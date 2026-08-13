import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
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
}
