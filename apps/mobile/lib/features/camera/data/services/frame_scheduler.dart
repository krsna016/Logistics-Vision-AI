import 'dart:async';
import 'package:camera/camera.dart';
import '../../domain/entities/detection.dart';
import '../../domain/repositories/inference_repository.dart';
import '../../../../utils/logger.dart';

class FrameScheduler {
  final InferenceRepository _repository;
  static const _minimumInferenceInterval = Duration(milliseconds: 140);

  bool _isProcessing = false;
  bool _isDisposed = false;
  CameraImage? _nextFrame;
  Timer? _wakeTimer;
  DateTime? _lastInferenceStart;
  int _droppedFrames = 0;

  final _detectionController = StreamController<List<Detection>>.broadcast();

  FrameScheduler(this._repository);

  Stream<List<Detection>> get detectionsStream => _detectionController.stream;
  int get droppedFramesCount => _droppedFrames;

  /// Schedule a camera frame for processing. Drops intermediate frames if busy.
  void scheduleFrame(CameraImage image) {
    if (_isDisposed) return;

    // Keep only the newest frame. Camera streams can deliver 30+ frames per
    // second while ONNX inference is much slower; retaining every frame makes
    // the queue stale and increases memory pressure.
    if (_nextFrame != null) {
      _droppedFrames++;
    }
    _nextFrame = image;
    _scheduleNextIfDue();
  }

  void _scheduleNextIfDue() {
    if (_isDisposed || _isProcessing || _nextFrame == null) return;

    final lastStart = _lastInferenceStart;
    final elapsed = lastStart == null
        ? _minimumInferenceInterval
        : DateTime.now().difference(lastStart);
    final remaining = _minimumInferenceInterval - elapsed;

    if (remaining > Duration.zero) {
      _wakeTimer ??= Timer(remaining, () {
        _wakeTimer = null;
        _scheduleNextIfDue();
      });
      return;
    }

    final frame = _nextFrame;
    _nextFrame = null;
    _isProcessing = true;
    _lastInferenceStart = DateTime.now();
    unawaited(_processFrame(frame!));
  }

  Future<void> _processFrame(CameraImage image) async {
    try {
      final results = await _repository.runInference(image);
      if (!_detectionController.isClosed) {
        _detectionController.add(results);
      }
    } catch (e, stack) {
      AppLogger.error(
          'Inference pipeline execution error in scheduler', e, stack);
    } finally {
      _isProcessing = false;

      // If a newer frame arrived while we were busy, execute it now.
      _scheduleNextIfDue();
    }
  }

  void resetTelemetry() {
    _droppedFrames = 0;
  }

  void dispose() {
    _isDisposed = true;
    _wakeTimer?.cancel();
    _wakeTimer = null;
    _nextFrame = null;
    _detectionController.close();
  }
}
