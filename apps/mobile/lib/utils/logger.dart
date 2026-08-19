import 'package:logger/logger.dart';
import '../config/environment.dart';
import 'file_logger.dart' as import_file_logger;

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
    level: Environment.current == Environment.production
        ? Level.warning
        : Level.debug,
  );

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
    try {
      import_file_logger.FileLogger.log('INFO: $message');
    } catch (_) {}
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
    try {
      import_file_logger.FileLogger.log('WARNING: $message ${error != null ? "- $error" : ""}');
    } catch (_) {}
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    try {
      import_file_logger.FileLogger.log('ERROR: $message ${error != null ? "- $error" : ""}');
    } catch (_) {}
  }

  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
    try {
      import_file_logger.FileLogger.log('FATAL: $message ${error != null ? "- $error" : ""}');
    } catch (_) {}
  }
}
