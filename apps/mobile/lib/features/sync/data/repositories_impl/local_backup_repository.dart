import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../domain/entities/backup_archive.dart';
import '../../domain/repositories/backup_repository.dart';

class LocalBackupRepository implements BackupRepository {
  LocalBackupRepository({Future<Directory> Function()? documentsDirectory})
      : _documentsDirectory =
            documentsDirectory ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _documentsDirectory;

  Future<Directory> _getBackupDirectory() async {
    final appDir = await _documentsDirectory();
    final backupDir = Directory(p.join(appDir.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  File _backupFile(Directory directory, String backupId) {
    final safeId = p.basename(backupId);
    if (safeId != backupId ||
        safeId.isEmpty ||
        safeId.contains('/') ||
        safeId.contains('\\')) {
      throw ArgumentError('Invalid backup identifier');
    }
    return File(p.join(directory.path, '$safeId.sqlite.bak'));
  }

  String _backupId(File file) =>
      p.basename(file.path).replaceFirst(RegExp(r'\.sqlite\.bak$'), '');

  @override
  Future<List<BackupArchive>> getBackups() async {
    final backupDir = await _getBackupDirectory();
    final List<BackupArchive> archives = [];

    await for (final entity in backupDir.list()) {
      if (entity is File && entity.path.endsWith('.sqlite.bak')) {
        final stat = await entity.stat();
        final name = _backupId(entity);

        archives.add(BackupArchive(
          id: name,
          createdAt: stat.modified,
          version: '1.0.1',
          sizeMB: stat.size / (1024 * 1024),
          createdBy: name.contains('auto') ? 'System' : 'Admin',
          isAutomatic: name.contains('auto'),
          status: BackupIntegrity.verified,
        ));
      }
    }

    archives.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return archives;
  }

  @override
  Future<BackupArchive> createBackup(
      {required bool isAutomatic, bool includeImages = false}) async {
    final backupDir = await _getBackupDirectory();
    final appDir = await _documentsDirectory();

    final dbFile = File(p.join(appDir.path, 'smartload_offline.sqlite'));
    if (!await dbFile.exists()) {
      throw Exception('Database file not found');
    }

    final prefix = isAutomatic ? 'auto' : 'manual';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupFile =
        File(p.join(backupDir.path, 'backup_${prefix}_$timestamp.sqlite.bak'));

    await dbFile.copy(backupFile.path);

    await _pruneBackups(backupDir, keep: 20);

    final stat = await backupFile.stat();
    return BackupArchive(
      id: _backupId(backupFile),
      createdAt: stat.modified,
      version: '1.0.1',
      sizeMB: stat.size / (1024 * 1024),
      createdBy: isAutomatic ? 'System' : 'Admin',
      isAutomatic: isAutomatic,
      status: BackupIntegrity.verified,
    );
  }

  @override
  Future<bool> restoreBackup(String backupId) async {
    final backupDir = await _getBackupDirectory();
    final backupFile = _backupFile(backupDir, backupId);

    if (!await backupFile.exists()) {
      return false;
    }

    final appDir = await _documentsDirectory();
    final dbFile = File(p.join(appDir.path, 'smartload_offline.sqlite'));

    // Copy the backup over the current DB
    await backupFile.copy(dbFile.path);
    return true;
  }

  @override
  Future<bool> verifyBackup(String backupId) async {
    final backupDir = await _getBackupDirectory();
    final backupFile = _backupFile(backupDir, backupId);
    return await backupFile.exists();
  }

  @override
  Future<void> deleteBackup(String backupId) async {
    final backupDir = await _getBackupDirectory();
    final backupFile = _backupFile(backupDir, backupId);
    if (await backupFile.exists()) {
      await backupFile.delete();
    }
  }

  @override
  Future<Map<String, double>> getStorageStatistics() async {
    final appDir = await _documentsDirectory();

    double getDirSizeMB(Directory dir) {
      if (!dir.existsSync()) return 0.0;
      int size = 0;
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is File) {
          size += entity.lengthSync();
        }
      }
      return size / (1024 * 1024);
    }

    final dbFile = File(p.join(appDir.path, 'smartload_offline.sqlite'));
    final dbSize =
        dbFile.existsSync() ? dbFile.lengthSync() / (1024 * 1024) : 0.0;

    final imagesDir = Directory(p.join(appDir.path, 'datasets'));
    final backupsDir = await _getBackupDirectory();

    return {
      'dbSize': dbSize,
      'imagesSize': getDirSizeMB(imagesDir),
      'backupsSize': getDirSizeMB(backupsDir),
      'freeSpace': 10240.0, // 10GB mock
    };
  }

  Future<void> _pruneBackups(Directory backupDir, {required int keep}) async {
    final files = <File>[];
    await for (final entity in backupDir.list()) {
      if (entity is File && entity.path.endsWith('.sqlite.bak')) {
        files.add(entity);
      }
    }
    files
        .sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    for (final file in files.skip(keep)) {
      await file.delete();
    }
  }
}
