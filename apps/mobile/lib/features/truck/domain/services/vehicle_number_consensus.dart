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

    final matches = _history.where((value) => value == candidate).length;
    return matches >= requiredMatches ? candidate : null;
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
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
