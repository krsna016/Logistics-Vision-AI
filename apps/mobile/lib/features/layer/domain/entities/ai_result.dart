import 'package:flutter/foundation.dart';
import 'dart:ui';
import '../../../camera/domain/entities/detection.dart';

@immutable
class AIResult {
  final List<Detection> detections;
  final int count;

  /// Number of defective cartons, included in [count].
  final int defectCount;
  final double averageConfidence;
  final double processingTimeMs;
  final String modelVersion;
  final DateTime inferenceTimestamp;
  final Size frameSize;
  final List<String> warnings;

  const AIResult({
    required this.detections,
    required this.count,
    this.defectCount = 0,
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
    int? defectCount,
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
      defectCount: defectCount ?? this.defectCount,
      averageConfidence: averageConfidence ?? this.averageConfidence,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
      modelVersion: modelVersion ?? this.modelVersion,
      inferenceTimestamp: inferenceTimestamp ?? this.inferenceTimestamp,
      frameSize: frameSize ?? this.frameSize,
      warnings: warnings ?? this.warnings,
    );
  }
}
