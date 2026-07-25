import 'package:flutter/foundation.dart';
import '../../domain/entities/detection.dart';
import '../../domain/entities/inference_telemetry.dart';

@immutable
class InferenceState {
  final List<Detection> detections;
  final InferenceTelemetry telemetry;
  final bool isDebugMode;
  final bool isModelLoaded;
  final String? errorMessage;

  const InferenceState({
    this.detections = const [],
    this.telemetry = const InferenceTelemetry(),
    this.isDebugMode = false,
    this.isModelLoaded = false,
    this.errorMessage,
  });

  InferenceState copyWith({
    List<Detection>? detections,
    InferenceTelemetry? telemetry,
    bool? isDebugMode,
    bool? isModelLoaded,
    String? errorMessage,
  }) {
    return InferenceState(
      detections: detections ?? this.detections,
      telemetry: telemetry ?? this.telemetry,
      isDebugMode: isDebugMode ?? this.isDebugMode,
      isModelLoaded: isModelLoaded ?? this.isModelLoaded,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
