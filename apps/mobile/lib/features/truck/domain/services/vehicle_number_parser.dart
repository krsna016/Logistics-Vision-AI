class VehicleNumberParser {
  VehicleNumberParser._();

  static String normalize(String raw) {
    final upper = raw
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '')
        .replaceFirst(RegExp(r'^IND'), '');
    if (upper.isEmpty) return '';

    // OCR commonly confuses these characters on reflective plates. Apply
    // conservative fixes only where the character is surrounded by digits.
    return upper
        .replaceAllMapped(RegExp(r'(?<=\d)O(?=\d)'), (_) => '0')
        .replaceAllMapped(RegExp(r'(?<=\d)I(?=\d)'), (_) => '1')
        .replaceAllMapped(RegExp(r'(?<=\d)B(?=\d)'), (_) => '8');
  }

  static bool looksLikeVehicleNumber(String value) {
    final normalized = normalize(value);
    if (normalized.length < 5 || normalized.length > 12) return false;

    // Supports common Indian private/commercial registration shapes while
    // retaining a fallback for fleet identifiers used by existing customers.
    final indianFormat = RegExp(r'^[A-Z]{2}\d{1,2}[A-Z]{0,3}\d{3,4}$');
    final bharatSeries = RegExp(r'^\d{2}BH\d{4}[A-Z]{2}$');
    final fleetFormat = RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Z0-9]{5,12}$');
    return indianFormat.hasMatch(normalized) ||
        bharatSeries.hasMatch(normalized) ||
        fleetFormat.hasMatch(normalized);
  }

  static bool looksLikeIndianVehicleNumber(String value) {
    final normalized = normalize(value);
    return RegExp(r'^[A-Z]{2}\d{1,2}[A-Z]{0,3}\d{3,4}$').hasMatch(normalized) ||
        RegExp(r'^\d{2}BH\d{4}[A-Z]{2}$').hasMatch(normalized);
  }

  static List<String> candidatesFromText(String text) {
    final rawCandidates = text
        .split(RegExp(r'[\r\n\s,;|]+'))
        .where((token) => token.toUpperCase() != 'IND')
        .map(normalize)
        .where((candidate) => candidate.isNotEmpty)
        .toSet()
        .toList();

    final candidates = <String>{...rawCandidates};
    for (final candidate in rawCandidates) {
      candidates.addAll(_correctedCandidates(candidate));
    }

    // Number plates are often printed on two rows. ML Kit returns those rows
    // as separate blocks/lines, so also test adjacent OCR tokens joined
    // together: AS01 + KC1812 -> AS01KC1812.
    final tokens = text
        .split(RegExp(r'[\r\n\s,;|]+'))
        .where((token) => token.toUpperCase() != 'IND')
        .map(normalize)
        .where((token) => token.isNotEmpty)
        .toList();
    for (var start = 0; start < tokens.length; start++) {
      var joined = '';
      for (var end = start; end < tokens.length && end < start + 4; end++) {
        joined += tokens[end];
        if (joined.length <= 12) {
          candidates.add(joined);
          candidates.addAll(_correctedCandidates(joined));
        }
      }
    }

    // Also handle OCR inserting spaces inside a row, e.g. "AS 01 KC 1812".
    final compact = normalize(text);
    if (compact.length <= 12) candidates.add(compact);
    candidates.addAll(_correctedCandidates(compact));

    final valid = candidates.where(looksLikeVehicleNumber).toList()
      ..sort((a, b) => _score(b).compareTo(_score(a)));
    if (valid.isNotEmpty) {
      valid.sort((a, b) {
        final scoreDifference = _score(b).compareTo(_score(a));
        return scoreDifference == 0
            ? b.length.compareTo(a.length)
            : scoreDifference;
      });
      return valid;
    }
    return rawCandidates;
  }

  static int _score(String value) {
    var score = 0;
    if (RegExp(r'^[A-Z]{2}\d{1,2}[A-Z]{0,3}\d{3,4}$').hasMatch(value)) {
      score += 5;
    }
    if (RegExp(r'^\d{2}BH\d{4}[A-Z]{2}$').hasMatch(value)) score += 8;
    if (RegExp(r'^[A-Z]{2}').hasMatch(value)) score += 3;
    if (RegExp(r'\d').hasMatch(value)) score += 2;
    if (RegExp(r'[A-Z]').hasMatch(value)) score += 1;
    if (value.length >= 8) score += 1;
    return score;
  }

  static Iterable<String> _correctedCandidates(String value) sync* {
    final source = normalize(value);
    if (source.length < 7 || source.length > 12) return;

    // Try the Indian registration layout explicitly. This corrects OCR
    // confusions only in positions that should be digits, preserving letters
    // such as S in the state/series portions.
    for (var regionDigits = 1; regionDigits <= 2; regionDigits++) {
      for (var seriesLetters = 0; seriesLetters <= 3; seriesLetters++) {
        final suffixLength = source.length - 2 - regionDigits - seriesLetters;
        if (suffixLength < 3 || suffixLength > 4) continue;
        final state = source.substring(0, 2);
        final region = _digitsOnly(source.substring(2, 2 + regionDigits));
        final seriesStart = 2 + regionDigits;
        final series =
            source.substring(seriesStart, seriesStart + seriesLetters);
        final suffix =
            _digitsOnly(source.substring(seriesStart + seriesLetters));
        if (state.length == 2 &&
            RegExp(r'^[A-Z]{2}$').hasMatch(state) &&
            RegExp(r'^[A-Z]*$').hasMatch(series) &&
            RegExp(r'^\d{1,2}[A-Z]{0,3}\d{3,4}$')
                .hasMatch('$region$series$suffix')) {
          yield '$state$region$series$suffix';
        }
      }
    }
  }

  static String _digitsOnly(String value) {
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
}
