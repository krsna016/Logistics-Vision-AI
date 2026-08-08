class WagonNumberParser {
  WagonNumberParser._();

  static String normalize(String raw) =>
      raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  static bool looksLikeWagonNumber(String value) {
    final normalized = normalize(value);
    return RegExp(r'^3\d{10}$').hasMatch(normalized) ||
        RegExp(r'^BCN(?:[A-Z][A-Z0-9]{0,7})?3\d{10}$').hasMatch(normalized);
  }

  static List<String> candidatesFromText(String text) {
    final tokens = text
        .split(RegExp(r'[\r\n\s,;|:/]+'))
        .map(normalize)
        .where((token) => token.isNotEmpty)
        .toList();
    final wagonClasses = _wagonClasses(tokens);
    final numbers = _wagonNumbers(tokens);
    final candidates = <String>{};

    for (final wagonClass in wagonClasses) {
      for (final number in numbers) {
        candidates.add('$wagonClass$number');
      }
    }
    candidates.addAll(numbers);

    final valid = candidates.where(looksLikeWagonNumber).toList()
      ..sort((a, b) => _score(b).compareTo(_score(a)));
    return valid;
  }

  static Set<String> _wagonClasses(List<String> tokens) {
    final classes = <String>{};
    for (var start = 0; start < tokens.length; start++) {
      var joined = '';
      for (var end = start; end < tokens.length && end <= start + 4; end++) {
        joined += tokens[end];
        if (joined.length > 10) break;
        final corrected = _correctWagonClass(joined);
        if (corrected != null) classes.add(corrected);
      }
    }
    return classes;
  }

  static Set<String> _wagonNumbers(List<String> tokens) {
    final numbers = <String>{};
    for (var start = 0; start < tokens.length; start++) {
      var joined = '';
      for (var end = start; end < tokens.length && end <= start + 3; end++) {
        final digits = _asDigits(tokens[end]);
        if (digits == null) break;
        joined += digits;
        if (joined.length > 11) break;
        if (RegExp(r'^3\d{10}$').hasMatch(joined)) numbers.add(joined);
      }
    }
    return numbers;
  }

  static String? _correctWagonClass(String value) {
    final normalized =
        normalize(value).replaceAllMapped(RegExp(r'(?<=M)[IL]$'), (_) => '1');
    if (RegExp(r'^BCN(?:[A-Z][A-Z0-9]{0,7})?$').hasMatch(normalized)) {
      return normalized;
    }
    return null;
  }

  static String? _asDigits(String value) {
    if (value.isEmpty || !RegExp(r'^[0-9OQDILZSGTB]+$').hasMatch(value)) {
      return null;
    }
    const replacements = <String, String>{
      'O': '0',
      'Q': '0',
      'D': '0',
      'I': '1',
      'L': '1',
      'Z': '2',
      'S': '5',
      'G': '6',
      'T': '7',
      'B': '8',
    };
    return value.split('').map((char) => replacements[char] ?? char).join();
  }

  static int _score(String value) {
    var score = 0;
    final classMatch = RegExp(r'^(BCN(?:[A-Z][A-Z0-9]{0,7})?)(3\d{10})$')
        .firstMatch(normalize(value));
    if (classMatch != null) {
      score += 20;
      // When OCR exposes BCN, BCNA and BCNAHSM1 as overlapping candidates,
      // retain the most complete visible class rather than the shortest one.
      score += classMatch.group(1)!.length - 3;
    }
    if (RegExp(r'3\d{10}$').hasMatch(value)) score += 12;
    return score;
  }
}
