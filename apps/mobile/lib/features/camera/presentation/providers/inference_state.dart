import 'package:flutter/foundation.dart';
import '../../domain/entities/detection.dart';
import '../../domain/entities/inference_telemetry.dart';

enum InferenceModelStatus { idle, loading, ready, error }

@immutable
class InferenceState {
  final List<Detection> detections;
  final InferenceTelemetry telemetry;
  final bool isDebugMode;
  final bool isModelLoaded;
  final InferenceModelStatus modelStatus;
  final String? errorMessage;

  const InferenceState({
    this.detections = const [],
    this.telemetry = const InferenceTelemetry(),
    this.isDebugMode = false,
    this.isModelLoaded = false,
    this.modelStatus = InferenceModelStatus.idle,
    this.errorMessage,
  });

  InferenceState copyWith({
    List<Detection>? detections,
    InferenceTelemetry? telemetry,
    bool? isDebugMode,
    bool? isModelLoaded,
    InferenceModelStatus? modelStatus,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InferenceState(
      detections: detections ?? this.detections,
      telemetry: telemetry ?? this.telemetry,
      isDebugMode: isDebugMode ?? this.isDebugMode,
      isModelLoaded: isModelLoaded ?? this.isModelLoaded,
      modelStatus: modelStatus ?? this.modelStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
