import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/truck/domain/services/vehicle_number_parser.dart';

void main() {
  test('joins a two-row plate and ignores the IND marker', () {
    final candidates = VehicleNumberParser.candidatesFromText(
      'IND\nAS01\nKC1812',
    );

    expect(candidates.first, 'AS01KC1812');
  });

  test('joins OCR tokens when spaces split one registration', () {
    final candidates = VehicleNumberParser.candidatesFromText(
      'AS 01 KC 1812',
    );

    expect(candidates.first, 'AS01KC1812');
  });

  test('corrects OCR letter-digit confusion in registration positions', () {
    final candidates = VehicleNumberParser.candidatesFromText(
      'ASO1 KC1812',
    );

    expect(candidates.first, 'AS01KC1812');
  });

  test('parses representative two-line Assam commercial plates', () {
    const samples = <String, String>{
      'IND\nAS01\nDC4577': 'AS01DC4577',
      'AS11C\nC8031': 'AS11CC8031',
      'AS 01 H\nC3251': 'AS01HC3251',
      'AS01\nFC0451': 'AS01FC0451',
      'AS01N\nC8766': 'AS01NC8766',
      'AS17C\n6247': 'AS17C6247',
      'AS25F\nC7943': 'AS25FC7943',
    };

    for (final entry in samples.entries) {
      final candidates = VehicleNumberParser.candidatesFromText(entry.key);
      expect(candidates.first, entry.value, reason: entry.key);
    }
  });
}
