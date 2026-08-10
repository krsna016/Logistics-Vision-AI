import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/decision_state.dart';
import '../../domain/entities/detection.dart';
import '../../domain/services/stability_analyzer.dart';
import 'inference_notifier.dart';

// Provider pointing to the stability decision notifier
final countingDecisionProvider =
    StateNotifierProvider.autoDispose<CountingDecisionNotifier, DecisionState>(
        (ref) {
  final analyzer = StabilityAnalyzer();
  final notifier = CountingDecisionNotifier(analyzer);

  // Listen to incoming real-time detections and pipe to analyzer
  final subscription = ref
      .read(inferenceNotifierProvider.notifier)
      .addListener((inferenceState) {
    if (inferenceState.isModelLoaded) {
      notifier.analyzeFrameDetections(inferenceState.detections);
    }
  });

  ref.onDispose(() {
    subscription();
    analyzer.reset();
  });

  return notifier;
});

class CountingDecisionNotifier extends StateNotifier<DecisionState> {
  final StabilityAnalyzer _analyzer;

  CountingDecisionNotifier(this._analyzer)
      : super(const DecisionState(status: CountingDecisionState.collecting));

  void analyzeFrameDetections(List<Detection> detections) {
    final nextState = _analyzer.addFrame(detections);
    state = nextState;
  }

  /// A gallery image is already a single finalized capture, so it should not
  /// be blocked by the live-camera multi-frame stability gate.
  void acceptGalleryDetections(List<Detection> detections) {
    final averageConfidence = detections.isEmpty
        ? 0.0
        : detections.fold<double>(
              0.0,
              (total, detection) => total + detection.confidence,
            ) /
            detections.length;
    state = DecisionState(
      status: detections.isEmpty
          ? CountingDecisionState.rejected
          : CountingDecisionState.readyForReview,
      stableCount: detections.length,
      averageConfidence: averageConfidence,
      stabilityScore: detections.isEmpty ? 0.0 : 1.0,
      qualityScore: averageConfidence,
      recommendedAction:
          detections.isEmpty ? 'No cartons detected' : 'Ready to review count',
      warnings:
          detections.isEmpty ? const ['No cartons were detected.'] : const [],
      processedFramesCount: 1,
    );
  }

  void resetAnalyzer() {
    _analyzer.reset();
    state = const DecisionState(status: CountingDecisionState.collecting);
  }
}
