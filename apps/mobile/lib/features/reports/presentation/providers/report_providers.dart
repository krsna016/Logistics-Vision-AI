import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart' hide ReportExport;
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories_impl/local_report_repository.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/services/report_services.dart';
import '../../data/services/pdf_report_service_impl.dart';
import '../../data/services/excel_report_service_impl.dart';
import '../../data/services/csv_export_service_impl.dart';
import '../../data/services/print_service_impl.dart';
import '../../data/services/share_service_impl.dart';
import '../../domain/entities/report_export.dart';
import '../../../../utils/logger.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return LocalReportRepository(ref.watch(databaseProvider));
});

final pdfReportServiceProvider = Provider<PdfReportService>((ref) {
  final user = ref.watch(authProvider);
  return PdfReportServiceImpl(
    ref.watch(databaseProvider),
    supervisorName: user?.name,
  );
});

final excelReportServiceProvider = Provider<ExcelReportService>((ref) {
  final user = ref.watch(authProvider);
  return ExcelReportServiceImpl(
    ref.watch(databaseProvider),
    supervisorName: user?.name,
  );
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

Future<void> logGeneratedReport(
  WidgetRef ref, {
  required ReportType reportType,
  required ExportFormat format,
  required ExportStatus status,
  required String subjectId,
  File? file,
  String? error,
}) async {
  final user = ref.read(authProvider);
  try {
    await ref.read(reportRepositoryProvider).logExport(ReportExport(
          id: 'exp_${DateTime.now().microsecondsSinceEpoch}',
          reportType: reportType,
          exportFormat: format,
          userId: user?.employeeId ?? 'unknown',
          exportedAt: DateTime.now(),
          status: status,
          filePath: file?.path,
          details: error == null
              ? 'Subject: $subjectId'
              : 'Subject: $subjectId; $error',
        ));
  } catch (logError, stack) {
    AppLogger.error('Could not write report export audit', logError, stack);
  }
}
