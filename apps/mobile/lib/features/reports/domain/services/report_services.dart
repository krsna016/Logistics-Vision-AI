import 'dart:io';

abstract class PdfReportService {
  Future<File> generateTruckReport({required String truckId});
  Future<File> generateWagonReport({required String wagonId});
  Future<File> generateDigitalRegisterReport({required String wagonId});
  Future<File> generateAnalyticsReport();
}

abstract class ExcelReportService {
  Future<File> generateTruckReport({required String truckId});
  Future<File> generateWagonReport({required String wagonId});
  Future<File> generateDigitalRegisterReport({required String wagonId});
  Future<File> generateAnalyticsReport();
}

abstract class CsvExportService {
  Future<File> exportDataset({required String datasetId});
  Future<File> exportAuditLogs();
}

abstract class PrintService {
  Future<bool> printPdf(File pdfFile);
}

abstract class ShareService {
  Future<void> shareFile(File file, {String? subject, String? text});
}

abstract class ReportTemplateService {
  // Can define specific layouts if needed, but often consumed internally by PdfReportService.
  // We'll keep it as a structural placeholder as requested.
}

abstract class ReportScheduler {
  Future<void> scheduleDailyReport(DateTime timeOfDay);
  Future<void> cancelScheduledReports();
}
