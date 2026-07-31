import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import '../../domain/services/report_services.dart';
import '../../../../core/database/app_database.dart';

class CsvExportServiceImpl implements CsvExportService {
  final AppDatabase _db;

  CsvExportServiceImpl(this._db);

  Future<File> _createFile(String prefix) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return File('${dir.path}/${prefix}_$timestamp.csv');
  }

  @override
  Future<File> exportDataset({required String datasetId}) async {
    // We can export image metadata for the given dataset/wagon/truck
    // Fetch all metadata
    final metadata = await _db.select(_db.imageMetadata).get();

    final List<List<dynamic>> rows = [
      [
        'Image ID',
        'Filename',
        'Capture Time',
        'Model Version',
        'Inference Time (ms)',
        'Confidence',
        'Detected Count',
        'Manual Count',
        'Final Count'
      ]
    ];

    for (final m in metadata) {
      rows.add([
        m.imageId,
        m.filename,
        m.captureTime.toIso8601String(),
        m.modelVersion ?? 'N/A',
        m.inferenceTimeMs.toStringAsFixed(2),
        m.averageConfidence.toStringAsFixed(2),
        m.detectedCount,
        m.manualCount ?? 'N/A',
        m.finalCount ?? 'N/A',
      ]);
    }

    final csvData = csv.encode(rows);
    final file = await _createFile('DATASET_$datasetId');
    await file.writeAsString(csvData);
    return file;
  }

  @override
  Future<File> exportAuditLogs() async {
    final logs = await _db.select(_db.auditLogs).get();

    final List<List<dynamic>> rows = [
      [
        'Log ID',
        'Timestamp',
        'User ID',
        'Action',
        'Entity Type',
        'Entity ID',
        'Details'
      ]
    ];

    for (final l in logs) {
      rows.add([
        l.id,
        l.timestamp.toIso8601String(),
        l.userId,
        l.action,
        l.entityType,
        l.entityId,
        l.details ?? 'N/A',
      ]);
    }

    final csvData = csv.encode(rows);
    final file = await _createFile('AUDIT_LOGS');
    await file.writeAsString(csvData);
    return file;
  }
}
