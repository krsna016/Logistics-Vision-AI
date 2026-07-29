import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/decision_state.dart';
import '../../domain/entities/detection.dart';
import '../../domain/services/stability_analyzer.dart';
import 'inference_notifier.dart';

// Provider pointing to the stability decision notifier
final countingDecisionProvider = StateNotifierProvider.autoDispose<CountingDecisionNotifier, DecisionState>((ref) {
  final analyzer = StabilityAnalyzer();
  final notifier = CountingDecisionNotifier(analyzer);
  
  // Listen to incoming real-time detections and pipe to analyzer
  final subscription = ref.read(inferenceNotifierProvider.notifier).addListener((inferenceState) {
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

  CountingDecisionNotifier(this._analyzer) : super(const DecisionState(status: CountingDecisionState.collecting));

  void analyzeFrameDetections(List<Detection> detections) {
    final nextState = _analyzer.addFrame(detections);
    state = nextState;
  }

  void resetAnalyzer() {
    _analyzer.reset();
    state = const DecisionState(status: CountingDecisionState.collecting);
  }
}
