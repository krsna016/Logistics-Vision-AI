import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/wagon/domain/services/wagon_number_parser.dart';

void main() {
  test('joins wagon class and eleven-digit number', () {
    final candidates = WagonNumberParser.candidatesFromText(
      'BCNAHSM1\n31142324907',
    );

    expect(candidates.first, 'BCNAHSM131142324907');
  });

  test('joins a number split over two lines', () {
    final candidates = WagonNumberParser.candidatesFromText(
      'BCNAM1\n300800\n33728',
    );

    expect(candidates.first, 'BCNAM130080033728');
  });

  test('ignores common wagon specification labels', () {
    final candidates = WagonNumberParser.candidatesFromText(
      'BCNAHSM1 311006 42760 CC TARE AREA',
    );

    expect(candidates.first, 'BCNAHSM131100642760');
  });
}
