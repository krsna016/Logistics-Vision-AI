import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../data/repositories_impl/local_report_repository.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/services/report_services.dart';
import '../../data/services/pdf_report_service_impl.dart';
import '../../data/services/excel_report_service_impl.dart';
import '../../data/services/csv_export_service_impl.dart';
import '../../data/services/print_service_impl.dart';
import '../../data/services/share_service_impl.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return LocalReportRepository(ref.watch(databaseProvider));
});

final pdfReportServiceProvider = Provider<PdfReportService>((ref) {
  return PdfReportServiceImpl(ref.watch(databaseProvider));
});

final excelReportServiceProvider = Provider<ExcelReportService>((ref) {
  return ExcelReportServiceImpl(ref.watch(databaseProvider));
});

final csvExportServiceProvider = Provider<CsvExportService>((ref) {
  return CsvExportServiceImpl(ref.watch(databaseProvider));
});

final printServiceProvider = Provider<PrintService>((ref) {
  return PrintServiceImpl();
});

final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareServiceImpl();
});
