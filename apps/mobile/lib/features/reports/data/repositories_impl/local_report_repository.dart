import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' hide ReportExport;
import '../../domain/entities/report_export.dart';
import '../../domain/repositories/report_repository.dart';

class LocalReportRepository implements ReportRepository {
  final AppDatabase _db;

  LocalReportRepository(this._db);

  @override
  Future<void> logExport(ReportExport exportRecord) async {
    await _db.into(_db.reportExports).insert(
          ReportExportsCompanion.insert(
            id: exportRecord.id,
            reportType: exportRecord.reportType.name,
            exportType: exportRecord.exportFormat.name,
            userId: exportRecord.userId,
            exportedAt: Value(exportRecord.exportedAt),
            status: exportRecord.status.name,
            filePath: Value(exportRecord.filePath),
            details: Value(exportRecord.details),
          ),
        );
  }

  @override
  Future<List<ReportExport>> getExportHistory({int limit = 50}) async {
    final results = await (_db.select(_db.reportExports)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.exportedAt, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .get();

    return results
        .map((r) => ReportExport(
              id: r.id,
              reportType: ReportType.values.firstWhere(
                  (e) => e.name == r.reportType,
                  orElse: () => ReportType.wagon),
              exportFormat: ExportFormat.values.firstWhere(
                  (e) => e.name == r.exportType,
                  orElse: () => ExportFormat.pdf),
              userId: r.userId,
              exportedAt: r.exportedAt,
              status: ExportStatus.values.firstWhere((e) => e.name == r.status,
                  orElse: () => ExportStatus.failed),
              filePath: r.filePath,
              details: r.details,
            ))
        .toList();
  }

  @override
  Future<void> clearExportHistory() async {
    await _db.delete(_db.reportExports).go();
  }
}
