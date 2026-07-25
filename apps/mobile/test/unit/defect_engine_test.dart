import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/features/defects/domain/entities/defect.dart';
import 'package:mobile/features/defects/domain/entities/quality_summary.dart';
import 'package:mobile/features/defects/data/repositories_impl/local_defect_repository.dart';
import 'package:mobile/features/camera/domain/entities/detection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QualitySummary Penalty & Quality Score Calculations', () {
    test('Calculates perfect quality score of 100 if no defects exist', () {
      const summary = QualitySummary(
        totalCartons: 10,
        defectiveCartons: 0,
        defects: [],
      );

      expect(summary.qualityScore, equals(100.0));
      expect(summary.defectPercentage, equals(0.0));
      expect(summary.hasCriticalIssues, isFalse);
    });

    test('Deducts severe penalty for Critical and High severity defects', () {
      final now = DateTime.now();
      final defects = [
        DefectRecord(
          id: 'def_1',
          layerId: 'layer_01',
          defectType: DefectType.broken,
          boundingBox: const BoundingBox(xMin: 0.1, yMin: 0.1, xMax: 0.3, yMax: 0.3),
          severity: DefectSeverity.critical,
          confidence: 0.94,
          modelVersion: '1.0.0',
          detectedAt: now,
        ),
        DefectRecord(
          id: 'def_2',
          layerId: 'layer_01',
          defectType: DefectType.torn,
          boundingBox: const BoundingBox(xMin: 0.4, yMin: 0.4, xMax: 0.6, yMax: 0.6),
          severity: DefectSeverity.low,
          confidence: 0.82,
          modelVersion: '1.0.0',
          detectedAt: now,
        ),
      ];

      final summary = QualitySummary(
        totalCartons: 10,
        defectiveCartons: 2,
        defects: defects,
      );

      // Penalties: Critical = 35, Low = 4. Total = 39.
      // Quality Score = 100 - 39 = 61.
      expect(summary.qualityScore, equals(61.0));
      expect(summary.defectPercentage, equals(20.0));
      expect(summary.hasCriticalIssues, isTrue);
    });

    test('Operator dismissals (false positive overrides) restore quality score penalties', () {
      final now = DateTime.now();
      final defects = [
        DefectRecord(
          id: 'def_1',
          layerId: 'layer_01',
          defectType: DefectType.broken,
          boundingBox: const BoundingBox(xMin: 0.1, yMin: 0.1, xMax: 0.3, yMax: 0.3),
          severity: DefectSeverity.critical,
          confidence: 0.94,
          confirmedByOperator: false, // Operator dismissed the defect
          modelVersion: '1.0.0',
          detectedAt: now,
        ),
      ];

      final summary = QualitySummary(
        totalCartons: 10,
        defectiveCartons: 0,
        defects: defects,
      );

      // Penalty should be ignored since the operator marked it as a false positive
      expect(summary.qualityScore, equals(100.0));
      expect(summary.hasCriticalIssues, isFalse);
    });
  });

  group('LocalDefectRepository Cache Persistence Tests', () {
    late LocalDefectRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({}); // Clean cache
      repository = LocalDefectRepository();
    });

    test('getDefectsByLayer returns initial mock seed entries', () async {
      final list = await repository.getDefectsByLayer('mock_l1');
      expect(list.length, equals(2));
      expect(list[0].defectType, equals(DefectType.crushed));
    });

    test('verifyDefect updates confirmation statuses', () async {
      await repository.getDefectsByLayer('mock_l1'); // Initialize seeds
      await repository.verifyDefect('mock_d1', confirmedByOperator: false, notes: 'False flag');

      final list = await repository.getDefectsByLayer('mock_l1');
      final target = list.firstWhere((element) => element.id == 'mock_d1');
      
      expect(target.confirmedByOperator, isFalse);
      expect(target.notes, equals('False flag'));
    });
  });
}
