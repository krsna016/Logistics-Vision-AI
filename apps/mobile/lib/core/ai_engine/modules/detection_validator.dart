import '../models/detection_result.dart';

enum ConfidenceTier { excellent, veryHigh, high, medium, needsReview }

class DetectionValidator {
  ConfidenceTier evaluateConfidence(double confidence) {
    if (confidence >= 0.95) return ConfidenceTier.excellent;
    if (confidence >= 0.90) return ConfidenceTier.veryHigh;
    if (confidence >= 0.80) return ConfidenceTier.high;
    if (confidence >= 0.70) return ConfidenceTier.medium;
    return ConfidenceTier.needsReview;
  }

  /// Filters out boxes that are below an absolute minimum acceptable tier
  List<DetectionResult> validate(List<DetectionResult> detections) {
    // In strict enterprise settings, we might reject boxes that completely fail sanity checks
    // The deployed Stage-1 checkpoint was count-calibrated at 0.27. Do not
    // silently apply a second, stricter threshold after post-processing.
    return detections.where((det) => det.confidence >= 0.27).toList();
  }
}
