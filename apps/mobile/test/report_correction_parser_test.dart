import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/reports/data/services/pdf_report_service_impl.dart';

void main() {
  test('separates correction reason from item changes', () {
    final parsed = parseLayerCorrectionDetails(
      'Layer 3: cartons 1 -> 6, defects 0 -> 0. Reason: ggg. '
      'Items: [{"itemName":"B","quantity":1}] -> '
      '[{"itemName":"B","quantity":6}]',
    );

    expect(parsed['reason'], 'ggg');
    expect(parsed['before'], 'Cartons: 1\nItems:\n  B: 1\nDefects: 0');
    expect(parsed['after'], 'Cartons: 6\nItems:\n  B: 6\nDefects: 0');
  });

  test('formats multiple corrected items on separate lines', () {
    final parsed = parseLayerCorrectionDetails(
      'Layer 1: cartons 64 -> 64, defects 0 -> 0. Reason: Reallocated. '
      'Items: [{"itemName":"A","quantity":40},'
      '{"itemName":"B","quantity":24}] -> '
      '[{"itemName":"A","quantity":35},'
      '{"itemName":"B","quantity":29}]',
    );

    expect(parsed['reason'], 'Reallocated');
    expect(parsed['before'], contains('A: 40\n  B: 24'));
    expect(parsed['after'], contains('A: 35\n  B: 29'));
  });
}
