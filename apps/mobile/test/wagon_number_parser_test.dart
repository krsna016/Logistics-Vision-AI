import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/wagon/domain/services/wagon_number_parser.dart';

void main() {
  test('joins wagon class and eleven-digit number', () {
    final candidates = WagonNumberParser.candidatesFromText(
      'BCNAHSM1\n31142324907',
    );

    expect(candidates.first, 'BCNAHSM131142324907');
  });

  test('joins wagon class with two numeric groups', () {
    final candidates = WagonNumberParser.candidatesFromText(
      'BCNAHSM1\n311006\n42760',
    );

    expect(candidates.first, 'BCNAHSM131100642760');
  });

  test('does not accept unrelated specification text as a wagon number', () {
    final candidates = WagonNumberParser.candidatesFromText(
      'BCNAHSM1 311006 42760 C.C. TARE AREA 66.96',
    );

    expect(candidates.first, 'BCNAHSM131100642760');
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

  test('normalizes a wagon class split by OCR whitespace', () {
    final candidates = WagonNumberParser.candidatesFromText(
      'BCNA HSM-1\n310324\n37595',
    );

    expect(candidates.first, 'BCNAHSM131032437595');
  });

  test('returns the full number when the BCN class is not visible', () {
    final candidates = WagonNumberParser.candidatesFromText(
      '310524\n14989',
    );

    expect(candidates.first, '31052414989');
  });

  test('preserves other BCN-family class markings', () {
    final candidates = WagonNumberParser.candidatesFromText(
      'BCNHL\n310524\n14989',
    );

    expect(candidates.first, 'BCNHL31052414989');
  });

  test('keeps a standalone BCN class when no suffix is visible', () {
    final candidates = WagonNumberParser.candidatesFromText(
      'BCN\n310524\n14989',
    );

    expect(candidates.first, 'BCN31052414989');
  });

  test('joins a wagon class split across several OCR tokens', () {
    final candidates = WagonNumberParser.candidatesFromText(
      'BCN A HSM 1\n310324\n37595',
    );

    expect(candidates.first, 'BCNAHSM131032437595');
  });

  test('does not accept an incomplete first numeric row', () {
    final candidates = WagonNumberParser.candidatesFromText(
      'BCNAHSM1\n310524',
    );

    expect(candidates, isEmpty);
  });

  test('parses the representative uploaded wagon markings', () {
    const samples = <String, String>{
      'BCNAM1\n300794\n20386': 'BCNAM130079420386',
      'BCNAM1\n300800\n33728': 'BCNAM130080033728',
      'BCNAHSM1\n31142324907': 'BCNAHSM131142324907',
      'BCNAHSM1\n311006\n42760': 'BCNAHSM131100642760',
      'BCNA HSM1\n310324\n37595': 'BCNAHSM131032437595',
      'BCNAHSM1\n310322\n11195': 'BCNAHSM131032211195',
      'BCNAM-1\n300201\n34365': 'BCNAM130020134365',
      'BCNAHSM-1\n311218\n10216': 'BCNAHSM131121810216',
      '31032427800': '31032427800',
    };

    for (final entry in samples.entries) {
      final candidates = WagonNumberParser.candidatesFromText(entry.key);
      expect(candidates.first, entry.value, reason: entry.key);
    }
  });
}
