import '../entities/backup_archive.dart';

abstract class BackupRepository {
  Future<List<BackupArchive>> getBackups();
  Future<BackupArchive> createBackup(
      {required bool isAutomatic, bool includeImages = false});
  Future<bool> restoreBackup(String backupId);
  Future<bool> verifyBackup(String backupId);
  Future<void> deleteBackup(String backupId);
  Future<Map<String, double>> getStorageStatistics();
}
