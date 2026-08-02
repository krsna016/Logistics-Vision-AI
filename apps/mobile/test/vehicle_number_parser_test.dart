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
}
