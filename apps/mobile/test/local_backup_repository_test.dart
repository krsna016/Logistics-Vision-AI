import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/sync/data/repositories_impl/local_backup_repository.dart';

void main() {
  late Directory appDirectory;

  setUp(() async {
    appDirectory =
        await Directory.systemTemp.createTemp('smartload_backup_test_');
  });

  tearDown(() async {
    await appDirectory.delete(recursive: true);
  });

  test('creates, verifies, and restores a local database backup', () async {
    final databaseFile = File('${appDirectory.path}/smartload_offline.sqlite');
    await databaseFile.writeAsString('original database');
    final repository =
        LocalBackupRepository(documentsDirectory: () async => appDirectory);

    final backup = await repository.createBackup(isAutomatic: false);
    await databaseFile.writeAsString('modified database');

    expect(await repository.verifyBackup(backup.id), isTrue);
    expect(await repository.restoreBackup(backup.id), isTrue);
    expect(await databaseFile.readAsString(), 'original database');
  });
}
