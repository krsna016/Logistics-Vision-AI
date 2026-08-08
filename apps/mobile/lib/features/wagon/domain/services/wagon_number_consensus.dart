class WagonNumberConsensus {
  final int requiredMatches;
  final int historyLimit;

  final List<String> _numberHistory = <String>[];
  String? _wagonClass;

  WagonNumberConsensus({
    this.requiredMatches = 3,
    this.historyLimit = 6,
  })  : assert(requiredMatches > 0),
        assert(historyLimit >= requiredMatches);

  String? addCandidates(Iterable<String> candidates) {
    final candidate = candidates.firstOrNull;
    if (candidate == null) return null;
    final match =
        RegExp(r'^(BCN[A-Z0-9]{2,7})?(3\d{10})$').firstMatch(candidate);
    if (match == null) return null;

    _wagonClass = match.group(1) ?? _wagonClass;
    final number = match.group(2)!;
    _numberHistory.add(number);
    if (_numberHistory.length > historyLimit) _numberHistory.removeAt(0);

    final matches = _numberHistory.where((value) => value == number).length;
    return matches >= requiredMatches ? '${_wagonClass ?? ''}$number' : null;
  }

  String? get leadingCandidate {
    if (_numberHistory.isEmpty) return null;
    final counts = <String, int>{};
    for (final number in _numberHistory) {
      counts[number] = (counts[number] ?? 0) + 1;
    }
    final number =
        counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    return '${_wagonClass ?? ''}$number';
  }

  void reset() {
    _numberHistory.clear();
    _wagonClass = null;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
