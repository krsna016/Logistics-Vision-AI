import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/wagon/domain/services/wagon_number_consensus.dart';

void main() {
  test('accepts a wagon after three matching number observations', () {
    final consensus = WagonNumberConsensus();

    expect(consensus.addCandidates(['31032437595']), isNull);
    expect(consensus.addCandidates(['BCNAHSM131032437595']), isNull);
    expect(
      consensus.addCandidates(['31032437595']),
      'BCNAHSM131032437595',
    );
  });

  test('keeps the BCN class when a later frame only reads the number', () {
    final consensus = WagonNumberConsensus(requiredMatches: 2);

    consensus.addCandidates(['BCNAM130080033728']);
    final result = consensus.addCandidates(['30080033728']);

    expect(result, 'BCNAM130080033728');
  });

  test('returns a number-only result when no BCN class appears', () {
    final consensus = WagonNumberConsensus(requiredMatches: 2);

    consensus.addCandidates(['31052414989']);

    expect(consensus.addCandidates(['31052414989']), '31052414989');
  });
}
