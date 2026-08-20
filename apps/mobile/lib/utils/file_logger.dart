import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive_io.dart';
import 'package:share_plus/share_plus.dart';

class FileLogger {
  static File? _currentLogFile;
  static String? _currentUserId;
  static final List<String> _writeQueue = [];
  static bool _isWriting = false;

  static Future<void> init() async {
    await _rotateLogFile();
  }

  static void setUserId(String userId) {
    _currentUserId = userId;
    log('User session started: $userId');
  }

  static Future<void> _rotateLogFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logsDir = Directory(p.join(dir.path, 'activity_logs'));
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _currentLogFile = File(p.join(logsDir.path, 'activity_$dateStr.log'));

      // Keep only last 30 days
      final files = await logsDir.list().toList();
      final cutoff = DateTime.now().subtract(const Duration(days: 30));
      for (final file in files) {
        if (file is File && file.path.endsWith('.log')) {
          final stat = await file.stat();
          if (stat.modified.isBefore(cutoff)) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      // ignore
    }
  }

  static Future<void> log(String message) async {
    // 1. FILTER SPAMMY DEVELOPER LOGS
    if (message.contains('NAVIGATED TO:') ||
        message.contains('RETURNED TO:') ||
        message.contains('Loaded ONNX model') ||
        message.contains('Unloaded AI model') ||
        message.contains('cold start took') ||
        message.contains('Initializing Logistics Vision AI')) {
      return;
    }

    if (_currentLogFile == null) await _rotateLogFile();
    if (_currentLogFile == null) return;

    // 2. BEAUTIFY THE MESSAGE FOR ADMINS
    String cleanMessage = message;
    if (cleanMessage.startsWith('INFO: ')) {
      cleanMessage = cleanMessage.substring(6);
    } else if (cleanMessage.startsWith('WARNING: ')) {
      cleanMessage = cleanMessage.substring(9);
    } else if (cleanMessage.startsWith('ERROR: ')) {
      cleanMessage = cleanMessage.substring(7);
    } else if (cleanMessage.startsWith('FATAL: ')) {
      cleanMessage = cleanMessage.substring(7);
    }

    if (cleanMessage.contains('ADMIN ACTION:')) {
      cleanMessage = cleanMessage.replaceFirst('ADMIN ACTION:', '🛠️ [ADMIN]');
    } else if (cleanMessage.contains('ADMIN IMPORT:')) {
      cleanMessage = cleanMessage.replaceFirst('ADMIN IMPORT:', '📦 [BACKUP]');
    } else if (cleanMessage.contains('Updated wagon')) {
      cleanMessage = '🚂 $cleanMessage';
    } else if (cleanMessage.contains('Updated truck')) {
      cleanMessage = '🚛 $cleanMessage';
    } else if (cleanMessage.contains('Updated layer')) {
      cleanMessage = '📦 $cleanMessage';
    } else if (cleanMessage.contains('Soft deleted') ||
        cleanMessage.contains('Archived') ||
        cleanMessage.contains('Deleted')) {
      cleanMessage = '🗑️ $cleanMessage';
    } else if (cleanMessage.contains('Created new')) {
      cleanMessage = '✨ $cleanMessage';
    } else if (cleanMessage.contains('export')) {
      cleanMessage = '📤 $cleanMessage';
    } else {
      cleanMessage = '📝 $cleanMessage';
    }

    final now = DateTime.now();
    final timeStr = DateFormat('hh:mm a').format(now); // Human readable time
    final userStr = _currentUserId != null ? '[$_currentUserId]' : '[LOCAL]';
    final logLine = '[$timeStr] $userStr $cleanMessage\n';

    // 3. QUEUE SYSTEM TO PREVENT CORRUPTED HALF-SENTENCES
    _writeQueue.add(logLine);
    _processQueue();
  }

  static Future<void> _processQueue() async {
    if (_isWriting || _writeQueue.isEmpty) return;
    _isWriting = true;

    try {
      while (_writeQueue.isNotEmpty) {
        final line = _writeQueue.removeAt(0);
        await _currentLogFile!
            .writeAsString(line, mode: FileMode.append, flush: true);
      }
    } catch (e) {
      // ignore
    } finally {
      _isWriting = false;
    }
  }

  static Future<void> exportLogs() async {
    try {
      log('Admin requested log export.');
      final dir = await getApplicationDocumentsDirectory();
      final logsDir = Directory(p.join(dir.path, 'activity_logs'));
      if (!await logsDir.exists()) return;

      final tempDir = await getTemporaryDirectory();
      final zipPath = p.join(tempDir.path,
          'SmartLoad_Activity_Logs_${DateTime.now().millisecondsSinceEpoch}.zip');

      final encoder = ZipFileEncoder();
      encoder.create(zipPath);

      final files = await logsDir.list().toList();
      bool hasFiles = false;
      for (final file in files) {
        if (file is File && file.path.endsWith('.log')) {
          encoder.addFile(file);
          hasFiles = true;
        }
      }
      encoder.close();

      if (hasFiles) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(zipPath)],
            text: 'SmartLoad Internal Activity Logs',
          ),
        );
      }
    } catch (e) {
      // ignore
    }
  }
}
