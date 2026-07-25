import 'package:flutter/foundation.dart';
import 'dart:ui';
import '../../../camera/domain/entities/detection.dart';

@immutable
class AIResult {
  final List<Detection> detections;
  final int count;
  final double averageConfidence;
  final double processingTimeMs;
  final String modelVersion;
  final DateTime inferenceTimestamp;
  final Size frameSize;
  final List<String> warnings;

  const AIResult({
    required this.detections,
    required this.count,
    required this.averageConfidence,
    required this.processingTimeMs,
    required this.modelVersion,
    required this.inferenceTimestamp,
    required this.frameSize,
    this.warnings = const [],
  });

  AIResult copyWith({
    List<Detection>? detections,
    int? count,
    double? averageConfidence,
    double? processingTimeMs,
    String? modelVersion,
    DateTime? inferenceTimestamp,
    Size? frameSize,
    List<String>? warnings,
  }) {
    return AIResult(
      detections: detections ?? this.detections,
      count: count ?? this.count,
      averageConfidence: averageConfidence ?? this.averageConfidence,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
      modelVersion: modelVersion ?? this.modelVersion,
      inferenceTimestamp: inferenceTimestamp ?? this.inferenceTimestamp,
      frameSize: frameSize ?? this.frameSize,
      warnings: warnings ?? this.warnings,
    );
  }
}
