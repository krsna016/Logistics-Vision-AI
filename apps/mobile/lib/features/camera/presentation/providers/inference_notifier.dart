import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/inference_repository.dart';
import '../../domain/entities/detection.dart';
import '../../data/repositories_impl/onnx_inference_repository.dart';
import '../../data/services/frame_scheduler.dart';
import 'inference_state.dart';
import '../../../../utils/logger.dart';

// Provider pointing to the concrete inference engine
final inferenceRepositoryProvider = Provider<InferenceRepository>((ref) {
  return ONNXInferenceRepository();
});

// App-scoped inference service. Once loaded, the large ONNX session stays warm
// across camera/review navigation and is released with the root ProviderScope.
final inferenceNotifierProvider =
    StateNotifierProvider<InferenceNotifier, InferenceState>((ref) {
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
  StreamSubscription<List<Detection>>? _detectionsSubscription;
  late final Future<void> _initialization;

  InferenceNotifier(this._repository, this._scheduler)
      : super(const InferenceState()) {
    _initialization = _initialize();
  }

  Future<void> ensureModelReady() => _initialization;

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
      rethrow;
    }
  }

  /// Process an incoming camera frame.
  void processImageFrame(CameraImage image) {
    if (!state.isModelLoaded) return;
    _scheduler.scheduleFrame(image);
  }

  Future<void> processGalleryImage(String imagePath) async {
    if (!state.isModelLoaded) {
      try {
        await _initialization;
      } catch (_) {
        return;
      }
    }
    try {
      final detections = await _repository.runGalleryInference(imagePath);
      state = state.copyWith(
        detections: detections,
        telemetry: _repository.getTelemetry(),
      );
    } catch (e, stack) {
      AppLogger.error('Failed to analyse gallery image', e, stack);
      state = state.copyWith(
        errorMessage: 'Could not analyse the selected image.',
      );
    }
  }

  /// Runs an exclusive inference pass against the saved full-quality photo.
  /// Live frames are paused and any in-flight pass is allowed to finish first,
  /// preventing the final count from racing stale camera work.
  Future<List<Detection>> finalizeCapturedImage(String imagePath) async {
    if (!state.isModelLoaded) await _initialization;
    _scheduler.pause();
    try {
      await _scheduler.whenIdle;
      final detections = await _repository.runGalleryInference(imagePath);
      state = state.copyWith(
        detections: detections,
        telemetry: _repository.getTelemetry().copyWith(
              droppedFramesCount: _scheduler.droppedFramesCount,
            ),
      );
      return detections;
    } catch (e, stack) {
      AppLogger.error('Failed to finalize captured layer image', e, stack);
      state = state.copyWith(
        errorMessage: 'Could not verify the captured layer image.',
      );
      rethrow;
    } finally {
      _scheduler.resume();
    }
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
