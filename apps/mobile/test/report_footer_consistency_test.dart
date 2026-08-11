import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:mobile/features/reports/data/services/report_template_service_impl.dart';

void main() {
  test('every report page uses the shared SmartLoad footer', () async {
    final source = await File(
      'lib/features/reports/data/services/pdf_report_service_impl.dart',
    ).readAsString();
    final pageBuilders = RegExp(r'pw\.MultiPage\(').allMatches(source).length;
    final sharedFooters = RegExp(
      r'footer: \(context\) => ReportTemplateServiceImpl\.buildFooter\(context\)',
    ).allMatches(source).length;

    expect(pageBuilders, greaterThan(0));
    expect(sharedFooters, pageBuilders);
    expect(source, isNot(contains("pw.Text('PAGE \${context.pageNumber}")));
  });

  test('shared footer numbers mixed landscape and portrait pages globally',
      () async {
    final pdf = pw.Document();
    List<pw.Widget> auditRows(String section) => List.generate(
          95,
          (index) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 5),
            child: pw.Text('$section audit row ${index + 1}'),
          ),
        );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        footer: ReportTemplateServiceImpl.buildFooter,
        build: (_) => auditRows('Landscape'),
      ),
    );
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        footer: ReportTemplateServiceImpl.buildFooter,
        build: (_) => auditRows('Portrait'),
      ),
    );

    final output = File('build/report_footer_audit.pdf');
    await output.parent.create(recursive: true);
    await output.writeAsBytes(await pdf.save(), flush: true);

    expect(await output.length(), greaterThan(1000));
  });
}
