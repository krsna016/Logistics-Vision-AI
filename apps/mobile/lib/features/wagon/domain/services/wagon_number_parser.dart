class WagonNumberParser {
  WagonNumberParser._();

  static String normalize(String raw) =>
      raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  static bool looksLikeWagonNumber(String value) {
    final normalized = normalize(value);
    final letters = RegExp(r'[A-Z]').allMatches(normalized).length;
    final digits = RegExp(r'\d').allMatches(normalized).length;
    return normalized.length >= 9 &&
        normalized.length <= 24 &&
        letters >= 3 &&
        digits >= 5;
  }

  static List<String> candidatesFromText(String text) {
    final tokens = text
        .split(RegExp(r'[\r\n\s,;|:/]+'))
        .map(normalize)
        .where((token) => token.isNotEmpty)
        .where((token) => !_isLabel(token))
        .toList();
    final candidates = <String>{};

    for (var start = 0; start < tokens.length; start++) {
      var joined = '';
      for (var end = start; end < tokens.length && end < start + 4; end++) {
        joined += tokens[end];
        if (joined.length >= 9 && joined.length <= 24) {
          candidates.add(joined);
        }
      }
    }

    final compact = normalize(text);
    if (compact.length >= 9 && compact.length <= 24) {
      candidates.add(compact);
    }

    final valid = candidates.where(looksLikeWagonNumber).toList()
      ..sort((a, b) => _score(b).compareTo(_score(a)));
    return valid.isNotEmpty ? valid : candidates.toList();
  }

  static bool _isLabel(String token) {
    const labels = {
      'IND',
      'CC',
      'TARE',
      'AREA',
      'CAPACITY',
      'UFMS',
      'UF MBS',
    };
    return labels.contains(token) || token.length < 3;
  }

  static int _score(String value) {
    final digits = RegExp(r'\d').allMatches(value).length;
    final letters = RegExp(r'[A-Z]').allMatches(value).length;
    var score = digits + letters;
    if (digits >= 10) score += 8;
    if (letters >= 5) score += 4;
    if (value.length >= 15) score += 3;
    return score;
  }
}
