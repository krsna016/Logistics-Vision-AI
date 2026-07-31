enum ReportType {
  dailyLoading,
  truck,
  wagon,
  loadingSession,
  aiDetection,
  dataset,
  operator,
  analytics,
  audit,
  backup
}

enum ExportFormat { pdf, excel, csv }

enum ExportStatus { pending, success, failed }

class ReportExport {
  final String id;
  final ReportType reportType;
  final ExportFormat exportFormat;
  final String userId;
  final DateTime exportedAt;
  final ExportStatus status;
  final String? filePath;
  final String? details;

  const ReportExport({
    required this.id,
    required this.reportType,
    required this.exportFormat,
    required this.userId,
    required this.exportedAt,
    required this.status,
    this.filePath,
    this.details,
  });

  factory ReportExport.create({
    required ReportType reportType,
    required ExportFormat exportFormat,
    required String userId,
    ExportStatus status = ExportStatus.pending,
    String? filePath,
    String? details,
  }) {
    return ReportExport(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      reportType: reportType,
      exportFormat: exportFormat,
      userId: userId,
      exportedAt: DateTime.now(),
      status: status,
      filePath: filePath,
      details: details,
    );
  }
}
