import 'package:logger/logger.dart';

enum AuditEvent {
  truckCreated,
  truckEdited,
  layerCaptured,
  manualCorrection,
  truckCompleted,
  registerGenerated,
  exportedPDF,
}

class AuditLogger {
  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: false,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
  );

  static void log(AuditEvent event, String message, {Map<String, dynamic>? metadata}) {
    // In a production app, this would write to a local secure audit file 
    // or push to a remote telemetry service.
    // For now, we will log it locally to console/device log for debugging and audit trailing.
    _logger.i('[AUDIT: ${event.name.toUpperCase()}] $message\nMetadata: $metadata');
  }
}
