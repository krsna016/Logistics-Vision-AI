import 'package:flutter/services.dart';

/// Formats input to uppercase and removes all spaces.
/// Ideal for vehicle numbers, wagon numbers, and registration IDs.
class UpperCaseNoSpaceTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String formattedText =
        newValue.text.toUpperCase().replaceAll(' ', '');
    return newValue.copyWith(
      text: formattedText,
      selection: newValue.selection.copyWith(
        baseOffset: formattedText.length,
        extentOffset: formattedText.length,
      ),
    );
  }
}

/// Formats input to Title Case (Capitalizes the first letter of each word).
/// Ideal for names, companies, and locations.
class TitleCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final String formattedText = newValue.text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    return newValue.copyWith(
      text: formattedText,
      selection: newValue.selection.copyWith(
        baseOffset: formattedText.length.clamp(0, formattedText.length),
        extentOffset: formattedText.length.clamp(0, formattedText.length),
      ),
    );
  }
}

/// Formats input to Sentence Case (Capitalizes only the first letter of the string).
/// Ideal for notes and remarks.
class SentenceCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final String formattedText =
        newValue.text[0].toUpperCase() + newValue.text.substring(1);

    return newValue.copyWith(
      text: formattedText,
      selection: newValue.selection.copyWith(
        baseOffset: formattedText.length.clamp(0, formattedText.length),
        extentOffset: formattedText.length.clamp(0, formattedText.length),
      ),
    );
  }
}

extension StringFormattingExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String toSentenceCase() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  String toIdentifierFormat() {
    if (isEmpty) return this;
    return toUpperCase().replaceAll(' ', '');
  }
}
