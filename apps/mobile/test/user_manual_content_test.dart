import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/manual_content.dart';

void main() {
  test('English manual covers the complete operational lifecycle', () {
    expect(userManualMarkdown.length, greaterThan(15000));
    for (final topic in [
      'Creating a wagon and item manifest',
      'Mixed-item layers',
      'Digital Register',
      'PDF and Excel reports',
      'Demo data',
      'Supervisor closing checklist',
    ]) {
      expect(userManualMarkdown, contains(topic));
    }
  });

  test('Hindi manual covers the same critical workflows', () {
    expect(userManualHindiMarkdown.length, greaterThan(12000));
    for (final topic in [
      'वैगन और आइटम मैनिफेस्ट बनाना',
      'मिश्रित आइटम वाली लेयर',
      'डिजिटल रजिस्टर',
      'PDF और Excel रिपोर्ट',
      'डेमो डेटा',
      'सुपरवाइजर की अंतिम चेकलिस्ट',
    ]) {
      expect(userManualHindiMarkdown, contains(topic));
    }
  });
}
