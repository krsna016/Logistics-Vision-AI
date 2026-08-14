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

  /// Performs final sanity validation after the configurable postprocessor.
  /// Confidence filtering belongs to Postprocessor; applying the historical
  /// fixed 0.27 threshold here would make lower user settings ineffective.
  List<DetectionResult> validate(List<DetectionResult> detections) {
    return detections
        .where((detection) =>
            detection.confidence.isFinite &&
            detection.confidence >= 0 &&
            detection.confidence <= 1)
        .toList(growable: false);
  }
}
