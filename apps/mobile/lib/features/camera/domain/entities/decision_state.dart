import 'package:flutter/foundation.dart';

enum CountingDecisionState {
  collecting,
  analyzing,
  stable,
  unstable,
  readyForReview,
  rejected,
  error,
}

@immutable
class DecisionState {
  final CountingDecisionState status;
  final int stableCount;
  final double averageConfidence;
  final double stabilityScore; // Range: 0.0 to 1.0
  final double qualityScore;   // Range: 0.0 to 1.0
  final String recommendedAction; // e.g. "Hold Camera Steady"
  final List<String> warnings;
  final int processedFramesCount;

  const DecisionState({
    required this.status,
    this.stableCount = 0,
    this.averageConfidence = 0.0,
    this.stabilityScore = 0.0,
    this.qualityScore = 0.0,
    this.recommendedAction = 'Hold Camera Steady',
    this.warnings = const [],
    this.processedFramesCount = 0,
  });

  DecisionState copyWith({
    CountingDecisionState? status,
    int? stableCount,
    double? averageConfidence,
    double? stabilityScore,
    double? qualityScore,
    String? recommendedAction,
    List<String>? warnings,
    int? processedFramesCount,
  }) {
    return DecisionState(
      status: status ?? this.status,
      stableCount: stableCount ?? this.stableCount,
      averageConfidence: averageConfidence ?? this.averageConfidence,
      stabilityScore: stabilityScore ?? this.stabilityScore,
      qualityScore: qualityScore ?? this.qualityScore,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      warnings: warnings ?? this.warnings,
      processedFramesCount: processedFramesCount ?? this.processedFramesCount,
    );
  }
}
