import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/inference_repository.dart';
import '../../domain/entities/detection.dart';
import '../../data/repositories_impl/onnx_inference_repository.dart';
import 'inference_state.dart';
import '../../../../utils/logger.dart';
import '../../../../core/providers/ai_camera_settings_provider.dart';

// Provider pointing to the concrete inference engine
final inferenceRepositoryProvider = Provider<InferenceRepository>((ref) {
  return ONNXInferenceRepository(
    settingsReady: ref.read(aiCameraSettingsLoaderProvider.future),
  );
});

// App-scoped inference service. Once loaded, the large ONNX session stays warm
// across camera/review navigation and is released with the root ProviderScope.
final inferenceNotifierProvider =
    StateNotifierProvider<InferenceNotifier, InferenceState>((ref) {
  final repository = ref.watch(inferenceRepositoryProvider);
  final notifier = InferenceNotifier(repository);

  ref.onDispose(() {
    notifier.releaseEngine();
  });

  return notifier;
});

class InferenceNotifier extends StateNotifier<InferenceState> {
  final InferenceRepository _repository;
  Future<void>? _initialization;

  InferenceNotifier(this._repository) : super(const InferenceState());

  /// Prepares the single app-scoped runtime. Concurrent callers share one
  /// Future and every workflow reuses the resulting ONNX session.
  Future<void> ensureModelReady() {
    if (state.isModelLoaded) return Future<void>.value();
    final existing = _initialization;
    if (existing != null) return existing;
    final initialization = _initialize();
    _initialization = initialization;
    unawaited(initialization.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {
        if (identical(_initialization, initialization)) {
          _initialization = null;
        }
      },
    ));
    return initialization;
  }

  Future<void> _initialize() async {
    state = state.copyWith(
      modelStatus: InferenceModelStatus.loading,
      clearError: true,
    );
    try {
      await _repository.loadModel();

      state = state.copyWith(
        isModelLoaded: true,
        modelStatus: InferenceModelStatus.ready,
        clearError: true,
      );
      AppLogger.info('InferenceNotifier setup completed successfully.');
    } catch (e, stack) {
      AppLogger.error(
          'Failed to configure InferenceNotifier session', e, stack);
      state = state.copyWith(
        modelStatus: InferenceModelStatus.error,
        errorMessage: 'Failed to configure neural network session.',
      );
      rethrow;
    }
  }

  /// Runs inference against the saved full-quality photo.
  /// The capture screen does not run a live image stream, so this starts
  /// directly without waiting for preview-frame work.
  Future<List<Detection>> finalizeCapturedImage(String imagePath) async {
    if (!state.isModelLoaded) await ensureModelReady();
    try {
      final detections = await _repository.runGalleryInference(imagePath);
      state = state.copyWith(
        detections: detections,
        telemetry: _repository.getTelemetry(),
      );
      return detections;
    } catch (e, stack) {
      AppLogger.error('Failed to finalize captured layer image', e, stack);
      state = state.copyWith(
        errorMessage: 'Could not verify the captured layer image.',
      );
      rethrow;
    }
  }

  Future<List<Detection>> finalizeCapturedImageBytes(
      Uint8List imageBytes) async {
    if (!state.isModelLoaded) await ensureModelReady();
    try {
      final detections = await _repository.runGalleryInferenceBytes(imageBytes);
      state = state.copyWith(
        detections: detections,
        telemetry: _repository.getTelemetry(),
      );
      return detections;
    } catch (e, stack) {
      AppLogger.error('Failed to finalize captured image bytes', e, stack);
      state = state.copyWith(
        errorMessage: 'Could not verify the captured layer image.',
      );
      rethrow;
    }
  }

  /// Toggle debug telemetry screen displays.
  void toggleDebugOverlay() {
    final nextMode = !state.isDebugMode;
    _repository.setDebugMode(nextMode);
    state = state.copyWith(isDebugMode: nextMode);
  }

  Future<void> releaseEngine() async {
    await _repository.release();
    _initialization = null;
  }

  Future<void> reloadModel() async {
    state = state.copyWith(
      isModelLoaded: false,
      modelStatus: InferenceModelStatus.loading,
      clearError: true,
    );
    try {
      await _repository.release();
      await _repository.loadModel();
      state = state.copyWith(
        isModelLoaded: true,
        modelStatus: InferenceModelStatus.ready,
        clearError: true,
      );
    } catch (error, stack) {
      AppLogger.error(
          'Failed to reload AI model after settings change', error, stack);
      state = state.copyWith(
        modelStatus: InferenceModelStatus.error,
        errorMessage: 'Could not switch the AI model size.',
      );
      rethrow;
    }
  }
}
