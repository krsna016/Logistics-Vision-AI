import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/truck/domain/services/vehicle_number_consensus.dart';

void main() {
  test('accepts a number after three agreeing observations', () {
    final consensus = VehicleNumberConsensus();

    expect(consensus.addCandidates(['AS01GC5231']), isNull);
    expect(consensus.addCandidates(['AS01GC5231']), isNull);
    expect(consensus.addCandidates(['AS01GC5231']), 'AS01GC5231');
  });

  test('does not accept a competing result after one observation', () {
    final consensus = VehicleNumberConsensus();

    consensus.addCandidates(['AS01GC5231']);
    consensus.addCandidates(['AS01GC5237']);
    final result = consensus.addCandidates(['AS01GC5231']);

    expect(result, isNull);
    expect(consensus.leadingCandidate, 'AS01GC5231');
    expect(consensus.matchesFor('AS01GC5231'), 2);
  });

  test('keeps only recent observations', () {
    final consensus = VehicleNumberConsensus(
      requiredMatches: 3,
      historyLimit: 3,
    );

    consensus.addCandidates(['AS01GC5231']);
    consensus.addCandidates(['AS01GC5231']);
    consensus.addCandidates(['AS01GC5237']);
    consensus.addCandidates(['AS01GC5237']);
    final result = consensus.addCandidates(['AS01GC5237']);

    expect(result, 'AS01GC5237');
  });
}
