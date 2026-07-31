import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/backup_archive.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../data/repositories_impl/local_backup_repository.dart';

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return LocalBackupRepository();
});

final backupListProvider = FutureProvider<List<BackupArchive>>((ref) async {
  return ref.watch(backupRepositoryProvider).getBackups();
});

final storageStatisticsProvider =
    FutureProvider<Map<String, double>>((ref) async {
  return ref.watch(backupRepositoryProvider).getStorageStatistics();
});

// Provides a way to trigger manual backups
final backupNotifierProvider =
    StateNotifierProvider<BackupNotifier, bool>((ref) {
  return BackupNotifier(ref.watch(backupRepositoryProvider), ref);
});

class BackupNotifier extends StateNotifier<bool> {
  final BackupRepository _repository;
  final Ref _ref;

  BackupNotifier(this._repository, this._ref) : super(false);

  Future<BackupArchive?> triggerManualBackup(
      {bool includeImages = false}) async {
    state = true; // is loading
    try {
      final backup = await _repository.createBackup(
          isAutomatic: false, includeImages: includeImages);
      _ref.invalidate(backupListProvider);
      _ref.invalidate(storageStatisticsProvider);
      return backup;
    } finally {
      state = false;
    }
  }
}
