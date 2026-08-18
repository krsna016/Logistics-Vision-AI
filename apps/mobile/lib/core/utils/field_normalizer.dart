class FieldNormalizer {
  static String code(String input) {
    if (input.isEmpty) return input;
    return input.toUpperCase().replaceAll(' ', '');
  }

  static String title(String input) {
    if (input.isEmpty) return input;
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  static String? text(String? input) {
    if (input == null || input.isEmpty) return input;
    final trim = input.trim();
    if (trim.isEmpty) return trim;
    return trim[0].toUpperCase() + trim.substring(1);
  }
}
