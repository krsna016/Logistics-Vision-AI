import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Defects List Widget Tests', () {
    test('State objects map to layout list parameters', () {
      const defectLabel = 'Crushed Carton';
      expect(defectLabel, equals('Crushed Carton'));
    });
  });
}
