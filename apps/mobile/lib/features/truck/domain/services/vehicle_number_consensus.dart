class VehicleNumberConsensus {
  final int requiredMatches;
  final int historyLimit;

  final List<String> _history = <String>[];

  VehicleNumberConsensus({
    this.requiredMatches = 3,
    this.historyLimit = 6,
  })  : assert(requiredMatches > 0),
        assert(historyLimit >= requiredMatches);

  String? addCandidates(Iterable<String> candidates) {
    final candidate = candidates.firstOrNull;
    if (candidate == null) return null;

    _history.add(candidate);
    if (_history.length > historyLimit) _history.removeAt(0);

    final matching = _history.where((value) => _sameReading(value, candidate));
    if (matching.length < requiredMatches) return null;

    // Prefer the most frequently observed exact spelling within the matching
    // group. This tolerates a single O/0-style OCR wobble without inventing a
    // new registration value.
    final counts = <String, int>{};
    for (final value in matching) {
      counts[value] = (counts[value] ?? 0) + 1;
    }
    final winner = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return winner.value >= 2 ? winner.key : null;
  }

  String? get leadingCandidate {
    if (_history.isEmpty) return null;
    final counts = <String, int>{};
    for (final value in _history) {
      counts[value] = (counts[value] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  int matchesFor(String candidate) =>
      _history.where((value) => value == candidate).length;

  void reset() => _history.clear();

  static bool _sameReading(String first, String second) {
    if (first == second) return true;
    if (first.length != second.length) return false;
    var differences = 0;
    for (var index = 0; index < first.length; index++) {
      final a = first[index];
      final b = second[index];
      if (a == b) continue;
      differences++;
      if (differences > 1 || !_knownOcrConfusion(a, b)) return false;
    }
    return differences == 1;
  }

  static bool _knownOcrConfusion(String first, String second) {
    const groups = ['0OQD', '1IL', '2Z', '5S', '6G', '7T', '8B'];
    return groups.any(
      (group) => group.contains(first) && group.contains(second),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
