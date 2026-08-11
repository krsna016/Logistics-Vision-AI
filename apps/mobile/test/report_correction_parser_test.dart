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
    expect(parsed['before'], 'Cartons: 1\nItems:\nB: 1 cartons\nDefects: 0');
    expect(parsed['after'], 'Cartons: 6\nItems:\nB: 6 cartons\nDefects: 0');
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
    expect(parsed['before'], contains('A: 40 cartons\nB: 24 cartons'));
    expect(parsed['after'], contains('A: 35 cartons\nB: 29 cartons'));
  });

  test('formats correction history as a compact field comparison', () {
    expect(
      formatCorrectionChanges(
        'Cartons: 71\nItems:\nA: 45 cartons\nB: 26 cartons\nDefects: 0',
        'Cartons: 71\nItems:\nA: 44 cartons\nB: 27 cartons\nDefects: 0',
      ),
      'Cartons: 71 -> 71\nA: 45 -> 44\nB: 26 -> 27\nDefects: 0 -> 0',
    );
  });

  test('aggregates repeated and mixed layer items dynamically', () {
    final summary = aggregateTruckItems(
      [
        {'Premium Rice': 60},
        {'Premium Rice': 20, 'Assam Tea': 40},
        {'Assam Tea': 10, 'Whole Spices': 30},
      ],
      160,
    );

    expect(summary, [
      {'name': 'Assam Tea', 'quantity': 50},
      {'name': 'Premium Rice', 'quantity': 80},
      {'name': 'Whole Spices', 'quantity': 30},
    ]);
  });

  test('keeps the item summary reconciled for legacy unassigned cartons', () {
    final summary = aggregateTruckItems(
      [
        {'Premium Rice': 60},
        {},
      ],
      100,
    );

    expect(summary, [
      {'name': 'Premium Rice', 'quantity': 60},
      {'name': 'Unspecified item', 'quantity': 40},
    ]);
  });

  test('recalculates item totals when corrected allocations change', () {
    final before = aggregateTruckItems(
      [
        {'Premium Rice': 20, 'Assam Tea': 35},
      ],
      55,
    );
    final after = aggregateTruckItems(
      [
        {'Premium Rice': 20, 'Assam Tea': 40},
      ],
      60,
    );

    expect(
      before.firstWhere((item) => item['name'] == 'Assam Tea')['quantity'],
      35,
    );
    expect(
      after.firstWhere((item) => item['name'] == 'Assam Tea')['quantity'],
      40,
    );
  });

  test('formats each digital register item on its own line', () {
    expect(
      compactDigitalRegisterItems(
        'Packaged Foods: 25 + Personal Care: 15',
      ),
      'Packaged Foods: 25\nPersonal Care: 15',
    );
  });

  test('formats one wagon truck item per line', () {
    expect(
      formatTruckItemBreakdown([
        {'name': 'Consumer Electronics', 'quantity': 70},
        {'name': 'Home Appliances', 'quantity': 50},
      ]),
      'Consumer Electronics: 70 cartons\nHome Appliances: 50 cartons',
    );
  });
}
