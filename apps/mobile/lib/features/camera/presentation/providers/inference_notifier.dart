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
  StreamSubscription<List<Detection>>? _detectionsSubscription;
  final List<_TrackedDetection> _tracks = [];
  final Completer<void> _modelReady = Completer<void>();

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
        final smoothedDetections = _smoothDetections(detections);
        final telemetry = _repository.getTelemetry().copyWith(
              droppedFramesCount: _scheduler.droppedFramesCount,
            );
        state = state.copyWith(
          detections: smoothedDetections,
          telemetry: telemetry,
        );
      });

      state = state.copyWith(isModelLoaded: true);
      if (!_modelReady.isCompleted) _modelReady.complete();
      AppLogger.info('InferenceNotifier setup completed successfully.');
    } catch (e, stack) {
      AppLogger.error(
          'Failed to configure InferenceNotifier session', e, stack);
      state = state.copyWith(
        errorMessage: 'Failed to configure neural network session.',
      );
      if (!_modelReady.isCompleted) _modelReady.completeError(e, stack);
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
        await _modelReady.future;
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

  /// Toggle debug telemetry screen displays.
  void toggleDebugOverlay() {
    final nextMode = !state.isDebugMode;
    _repository.setDebugMode(nextMode);
    state = state.copyWith(isDebugMode: nextMode);
  }

  Future<void> releaseEngine() async {
    await _detectionsSubscription?.cancel();
    _tracks.clear();
    await _repository.release();
  }

  List<Detection> _smoothDetections(List<Detection> detections) {
    const matchThreshold = 0.25;
    const smoothing = 0.38;
    const maxMissedFrames = 3;
    final matchedTrackIndexes = <int>{};
    final nextTracks = <_TrackedDetection>[];

    for (final detection in detections) {
      var bestIndex = -1;
      var bestIou = matchThreshold;

      for (var index = 0; index < _tracks.length; index++) {
        if (matchedTrackIndexes.contains(index)) continue;
        final iou = _intersectionOverUnion(
          _tracks[index].detection.boundingBox,
          detection.boundingBox,
        );
        if (iou > bestIou) {
          bestIou = iou;
          bestIndex = index;
        }
      }

      if (bestIndex >= 0) {
        final previous = _tracks[bestIndex];
        matchedTrackIndexes.add(bestIndex);
        nextTracks.add(
          _TrackedDetection(
            detection: previous.detection.copyWith(
              boundingBox: _interpolateBox(
                previous.detection.boundingBox,
                detection.boundingBox,
                smoothing,
              ),
              confidence: detection.confidence,
            ),
            missedFrames: 0,
          ),
        );
      } else {
        nextTracks.add(_TrackedDetection(detection: detection));
      }
    }

    for (var index = 0; index < _tracks.length; index++) {
      if (matchedTrackIndexes.contains(index)) continue;
      final previous = _tracks[index];
      final missedFrames = previous.missedFrames + 1;
      if (missedFrames <= maxMissedFrames) {
        nextTracks.add(
          _TrackedDetection(
            detection: previous.detection,
            missedFrames: missedFrames,
          ),
        );
      }
    }

    _tracks
      ..clear()
      ..addAll(nextTracks);
    return nextTracks.map((track) => track.detection).toList(growable: false);
  }

  double _intersectionOverUnion(BoundingBox first, BoundingBox second) {
    final left = first.xMin > second.xMin ? first.xMin : second.xMin;
    final top = first.yMin > second.yMin ? first.yMin : second.yMin;
    final right = first.xMax < second.xMax ? first.xMax : second.xMax;
    final bottom = first.yMax < second.yMax ? first.yMax : second.yMax;
    final intersection =
        (right - left).clamp(0.0, 1.0) * (bottom - top).clamp(0.0, 1.0);
    if (intersection <= 0) return 0;

    final firstArea = (first.xMax - first.xMin) * (first.yMax - first.yMin);
    final secondArea =
        (second.xMax - second.xMin) * (second.yMax - second.yMin);
    final union = firstArea + secondArea - intersection;
    return union <= 0 ? 0 : intersection / union;
  }

  BoundingBox _interpolateBox(
    BoundingBox previous,
    BoundingBox current,
    double amount,
  ) {
    double lerp(double start, double end) => start + (end - start) * amount;

    return BoundingBox(
      xMin: lerp(previous.xMin, current.xMin),
      yMin: lerp(previous.yMin, current.yMin),
      xMax: lerp(previous.xMax, current.xMax),
      yMax: lerp(previous.yMax, current.yMax),
    );
  }
}

class _TrackedDetection {
  final Detection detection;
  final int missedFrames;

  const _TrackedDetection({required this.detection, this.missedFrames = 0});
}
