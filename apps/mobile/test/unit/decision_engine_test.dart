import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/features/camera/domain/entities/detection.dart';
import 'package:mobile/features/camera/domain/entities/decision_state.dart';
import 'package:mobile/features/camera/domain/services/stability_analyzer.dart';
import 'package:mobile/features/camera/presentation/providers/decision_providers.dart';

void main() {
  group('StabilityAnalyzer Voting & Majority Mode Algorithms', () {
    test('Window Mode resolves to majority count under fluctuating frame noise', () {
      final analyzer = StabilityAnalyzer(windowSize: 6);

      // Frame 1: 34 detections
      analyzer.addFrame(_generateDetectionsList(34, 0.90));
      // Frame 2: 35 detections
      analyzer.addFrame(_generateDetectionsList(35, 0.92));
      // Frame 3: 35 detections
      analyzer.addFrame(_generateDetectionsList(35, 0.89));
      // Frame 4: 34 detections
      analyzer.addFrame(_generateDetectionsList(34, 0.91));
      // Frame 5: 35 detections
      final state = analyzer.addFrame(_generateDetectionsList(35, 0.93));

      // Total processed frames is 5. Counts are [34, 35, 35, 34, 35]
      // 35 appears 3 times (60% mode frequency), 34 appears twice (40% frequency).
      // Mode count must resolve to 35.
      expect(state.stableCount, equals(35));
    });

    test('Decision state transitions to ReadyForReview when stability and confidence criteria are met', () {
      final analyzer = StabilityAnalyzer(windowSize: 5, stabilityThreshold: 0.70, confidenceThreshold: 0.80);

      // Feed 5 consecutive frames with identical counts (10 cartons) and high confidence (0.90)
      analyzer.addFrame(_generateDetectionsList(10, 0.90));
      analyzer.addFrame(_generateDetectionsList(10, 0.91));
      analyzer.addFrame(_generateDetectionsList(10, 0.92));
      analyzer.addFrame(_generateDetectionsList(10, 0.89));
      final state = analyzer.addFrame(_generateDetectionsList(10, 0.93));

      // Stability: 100% (exceeds threshold 70%)
      // Conf Avg: 91% (exceeds threshold 80%)
      // Status must transition to ReadyForReview
      expect(state.status, equals(CountingDecisionState.readyForReview));
      expect(state.recommendedAction, contains('Ready to capture'));
    });

    test('Decision state warns and flags unstable status when counts vary widely', () {
      final analyzer = StabilityAnalyzer(windowSize: 5, stabilityThreshold: 0.80);

      // Feed fluctuating counts: 10, 12, 10, 11, 10
      // Mode count is 10 (frequency = 3 / 5 = 60%, below 80% threshold)
      analyzer.addFrame(_generateDetectionsList(10, 0.90));
      analyzer.addFrame(_generateDetectionsList(12, 0.91));
      analyzer.addFrame(_generateDetectionsList(10, 0.92));
      analyzer.addFrame(_generateDetectionsList(11, 0.89));
      final state = analyzer.addFrame(_generateDetectionsList(10, 0.93));

      expect(state.status, equals(CountingDecisionState.unstable));
      expect(state.warnings.first, contains('Inconsistent counts'));
    });
  });
}

List<Detection> _generateDetectionsList(int count, double confidence) {
  return List.generate(
    count,
    (index) => Detection(
      id: 'det_$index',
      boundingBox: const BoundingBox(xMin: 0.1, yMin: 0.1, xMax: 0.4, yMax: 0.4),
      label: 'carton',
      confidence: confidence,
    ),
  );
}
