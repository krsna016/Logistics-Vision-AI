import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:logger/logger.dart';

class BackupService {
  final Logger _logger = Logger();

  Future<void> createLocalBackup() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final originalFile =
          File(p.join(dbFolder.path, 'smartload_offline.sqlite'));

      if (!await originalFile.exists()) {
        _logger.w('No database found to backup.');
        return;
      }

      final backupFolder = await _getBackupPath();
      final backupFileName =
          'backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.sqlite';
      final backupFile = File(p.join(backupFolder, backupFileName));

      await originalFile.copy(backupFile.path);
      _logger.i('Local backup created successfully at: ${backupFile.path}');
    } catch (e) {
      _logger.e('Failed to create local backup: $e');
    }
  }

  Future<void> restoreBackup(String backupFilePath) async {
    try {
      final backupFile = File(backupFilePath);
      if (!await backupFile.exists()) {
        throw Exception('Backup file does not exist');
      }

      final dbFolder = await getApplicationDocumentsDirectory();
      final currentDbFile =
          File(p.join(dbFolder.path, 'smartload_offline.sqlite'));

      // Copy current to a safe place just in case
      if (await currentDbFile.exists()) {
        await currentDbFile
            .copy(p.join(dbFolder.path, 'smartload_offline.sqlite.temp'));
      }

      await backupFile.copy(currentDbFile.path);
      _logger.i('Database restored successfully from $backupFilePath');
    } catch (e) {
      _logger.e('Failed to restore backup: $e');
      throw Exception('Restore failed');
    }
  }

  Future<String> _getBackupPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, 'backups');
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }
}
