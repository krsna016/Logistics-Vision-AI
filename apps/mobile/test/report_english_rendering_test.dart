import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/reports/data/services/pdf_report_service_impl.dart';

void main() {
  test('wagon report uses the original English PDF fonts and layout', () async {
    final printedMessages = <String>[];
    final bytes = await runZoned(
      () => buildWagonPdfBytesForTesting(
        {
          'wagonNumber': 'BCNHL 700301',
          'loadingDate': '2026-08-20',
          'status': 'Completed',
          'origin': 'Raipur',
          'destination': 'Mumbai',
          'remarks': 'Report verified',
          'items': [
            {
              'name': 'Boxes',
              'total': 40,
              'loaded': 40,
              'remaining': 0,
            },
          ],
          'trucks': [
            {
              'vehicleNumber': 'CG 23 AB 4101',
              'driverName': 'Ravi Kumar',
              'driverMobile': '+91 98000 41001',
              'totalLayers': 1,
              'totalCartons': 40,
              'totalDefects': 1,
              'itemBreakdown': 'Boxes: 40 cartons',
              'status': 'Completed',
            },
          ],
          'corrections': <Map<String, Object?>>[],
        },
        supervisor: 'Amit Sharma',
      ),
      zoneSpecification: ZoneSpecification(
        print: (_, __, ___, message) => printedMessages.add(message),
      ),
    );

    expect(
      printedMessages.where(
        (message) => message.contains('Unable to find a font to draw'),
      ),
      isEmpty,
    );

    final pdfSource = latin1.decode(bytes, allowInvalid: true);
    expect(pdfSource, contains('/BaseFont/Helvetica'));
    expect(pdfSource, isNot(contains('NotoSans')));

    final output = File('build/report_english_commit_style.pdf');
    await output.parent.create(recursive: true);
    await output.writeAsBytes(bytes, flush: true);
    expect(await output.length(), greaterThan(5000));
  });
}
