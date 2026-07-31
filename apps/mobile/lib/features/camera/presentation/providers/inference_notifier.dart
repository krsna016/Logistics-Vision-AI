import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/inference_repository.dart';
import '../../data/repositories_impl/onnx_inference_repository.dart';
import '../../data/services/frame_scheduler.dart';
import 'inference_state.dart';
import '../../../../utils/logger.dart';

// Provider pointing to the concrete inference engine
final inferenceRepositoryProvider = Provider<InferenceRepository>((ref) {
  return ONNXInferenceRepository();
});

// Auto-disposed StateNotifierProvider for tracking inference metrics
final inferenceNotifierProvider =
    StateNotifierProvider.autoDispose<InferenceNotifier, InferenceState>((ref) {
  final repository = ref.watch(inferenceRepositoryProvider);
  final scheduler = FrameScheduler(repository);

  final notifier = InferenceNotifier(repository, scheduler);

  ref.onDispose(() {
    scheduler.dispose();
    notifier.releaseEngine();
  });

  return notifier;
});

class InferenceNotifier extends StateNotifier<InferenceState> {
  final InferenceRepository _repository;
  final FrameScheduler _scheduler;
  StreamSubscription? _detectionsSubscription;

  InferenceNotifier(this._repository, this._scheduler)
      : super(const InferenceState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _repository.loadModel();

      // Subscribe to scheduler outputs
      _detectionsSubscription =
          _scheduler.detectionsStream.listen((detections) {
        final telemetry = _repository.getTelemetry().copyWith(
              droppedFramesCount: _scheduler.droppedFramesCount,
            );
        state = state.copyWith(
          detections: detections,
          telemetry: telemetry,
        );
      });

      state = state.copyWith(isModelLoaded: true);
      AppLogger.info('InferenceNotifier setup completed successfully.');
    } catch (e, stack) {
      AppLogger.error(
          'Failed to configure InferenceNotifier session', e, stack);
      state = state.copyWith(
        errorMessage: 'Failed to configure neural network session.',
      );
    }
  }

  /// Process an incoming camera frame.
  void processImageFrame(CameraImage image) {
    if (!state.isModelLoaded) return;
    _scheduler.scheduleFrame(image);
  }

  /// Toggle debug telemetry screen displays.
  void toggleDebugOverlay() {
    final nextMode = !state.isDebugMode;
    _repository.setDebugMode(nextMode);
    state = state.copyWith(isDebugMode: nextMode);
  }

  Future<void> releaseEngine() async {
    await _detectionsSubscription?.cancel();
    await _repository.release();
  }
}
