import 'dart:math';
import '../entities/detection.dart';
import '../entities/decision_state.dart';

class StabilityAnalyzer {
  final int windowSize;
  final double stabilityThreshold; // Minimum stability score to confirm (e.g. 0.85)
  final double confidenceThreshold; // Minimum average confidence (e.g. 0.75)
  
  final List<List<Detection>> _frameHistory = [];
  final List<int> _countHistory = [];

  StabilityAnalyzer({
    this.windowSize = 10,
    this.stabilityThreshold = 0.85,
    this.confidenceThreshold = 0.75,
  });

  /// Feeds a new frame detection list, recalculates metrics, and returns the updated state.
  DecisionState addFrame(List<Detection> detections) {
    _frameHistory.add(detections);
    _countHistory.add(detections.length);

    if (_frameHistory.length > windowSize) {
      _frameHistory.removeAt(0);
      _countHistory.removeAt(0);
    }

    final frameCount = _frameHistory.length;
    if (frameCount < 5) {
      // Need minimum of 5 frames to start analyzing stability
      return DecisionState(
        status: CountingDecisionState.collecting,
        stableCount: detections.length,
        processedFramesCount: frameCount,
        recommendedAction: 'Collecting frames... Hold camera steady',
      );
    }

    // 1. Calculate Average Confidence
    double totalConf = 0.0;
    int detectionsCount = 0;
    for (final frame in _frameHistory) {
      for (final det in frame) {
        totalConf += det.confidence;
        detectionsCount++;
      }
    }
    final avgConf = detectionsCount > 0 ? totalConf / detectionsCount : 0.0;

    // 2. Sliding Window Analysis: Compute Majority/Mode Count
    final countFrequencies = <int, int>{};
    for (final c in _countHistory) {
      countFrequencies[c] = (countFrequencies[c] ?? 0) + 1;
    }
    
    int modeCount = _countHistory.last;
    int maxFrequency = 0;
    countFrequencies.forEach((count, freq) {
      if (freq > maxFrequency) {
        maxFrequency = freq;
        modeCount = count;
      }
    });

    // 3. Compute Stability Score (Frame agreement percentage)
    final double stabilityScore = maxFrequency / frameCount;

    // 4. Compute Quality Score (weighted average of stability and confidence)
    final double qualityScore = (stabilityScore * 0.4) + (avgConf * 0.6);

    // 5. Determine Warnings & Recommended Action
    final List<String> warnings = [];
    String action = 'Hold Camera Steady';
    CountingDecisionState nextStatus = CountingDecisionState.analyzing;

    if (avgConf < confidenceThreshold) {
      warnings.add('Low lighting or poor carton focus.');
      action = 'Move camera closer and improve lighting';
    }

    if (stabilityScore < stabilityThreshold) {
      warnings.add('Inconsistent counts. Detections fluctuating.');
      action = 'Hold camera steady';
      nextStatus = CountingDecisionState.unstable;
    } else if (avgConf >= confidenceThreshold) {
      action = 'Ready to capture!';
      nextStatus = CountingDecisionState.readyForReview;
    }

    return DecisionState(
      status: nextStatus,
      stableCount: modeCount,
      averageConfidence: avgConf,
      stabilityScore: stabilityScore,
      qualityScore: qualityScore,
      recommendedAction: action,
      warnings: warnings,
      processedFramesCount: frameCount,
    );
  }

  void reset() {
    _frameHistory.clear();
    _countHistory.clear();
  }
}
