import '../entities/report_export.dart';

abstract class ReportRepository {
  Future<void> logExport(ReportExport exportRecord);
  Future<List<ReportExport>> getExportHistory({int limit = 50});
  Future<void> clearExportHistory();
  
  // Data Aggregation methods for complex reports can go here.
  // We'll primarily rely on existing feature repositories, but ReportRepository
  // can serve as a facade if needed to aggregate disparate data for heavy analytics.
}
