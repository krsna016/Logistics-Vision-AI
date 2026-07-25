import 'package:flutter/foundation.dart';

@immutable
class InferenceTelemetry {
  final double fps;
  final double averageLatencyMs;
  final double preprocessingTimeMs;
  final double inferenceTimeMs;
  final double postprocessingTimeMs;
  final int droppedFramesCount;
  final int totalDetectionsCount;
  final String modelVersion;

  const InferenceTelemetry({
    this.fps = 0.0,
    this.averageLatencyMs = 0.0,
    this.preprocessingTimeMs = 0.0,
    this.inferenceTimeMs = 0.0,
    this.postprocessingTimeMs = 0.0,
    this.droppedFramesCount = 0,
    this.totalDetectionsCount = 0,
    this.modelVersion = '1.0.0-YOLOv8n',
  });

  InferenceTelemetry copyWith({
    double? fps,
    double? averageLatencyMs,
    double? preprocessingTimeMs,
    double? inferenceTimeMs,
    double? postprocessingTimeMs,
    int? droppedFramesCount,
    int? totalDetectionsCount,
    String? modelVersion,
  }) {
    return InferenceTelemetry(
      fps: fps ?? this.fps,
      averageLatencyMs: averageLatencyMs ?? this.averageLatencyMs,
      preprocessingTimeMs: preprocessingTimeMs ?? this.preprocessingTimeMs,
      inferenceTimeMs: inferenceTimeMs ?? this.inferenceTimeMs,
      postprocessingTimeMs: postprocessingTimeMs ?? this.postprocessingTimeMs,
      droppedFramesCount: droppedFramesCount ?? this.droppedFramesCount,
      totalDetectionsCount: totalDetectionsCount ?? this.totalDetectionsCount,
      modelVersion: modelVersion ?? this.modelVersion,
    );
  }
}
