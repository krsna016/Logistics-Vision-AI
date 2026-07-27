import 'dart:io';
import 'package:printing/printing.dart';
import '../../domain/services/report_services.dart';

class PrintServiceImpl implements PrintService {
  @override
  Future<bool> printPdf(File pdfFile) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: pdfFile.uri.pathSegments.last,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
