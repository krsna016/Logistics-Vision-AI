import 'dart:async';
import 'package:camera/camera.dart';
import '../../domain/entities/detection.dart';
import '../../domain/repositories/inference_repository.dart';
import '../../../../utils/logger.dart';

class FrameScheduler {
  final InferenceRepository _repository;
  static const _minimumInferenceGap = Duration(milliseconds: 120);

  bool _isProcessing = false;
  bool _isPaused = false;
  bool _isDisposed = false;
  DateTime _nextEligibleAt = DateTime.now();
  int _droppedFrames = 0;

  final _detectionController = StreamController<List<Detection>>.broadcast();

  FrameScheduler(this._repository);

  Stream<List<Detection>> get detectionsStream => _detectionController.stream;
  int get droppedFramesCount => _droppedFrames;
  Future<void> get whenIdle async {
    while (_isProcessing && !_isDisposed) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  /// Schedule a camera frame for processing. Drops intermediate frames if busy.
  void scheduleFrame(CameraImage image) {
    if (_isDisposed || _isPaused) return;
    if (_isProcessing || DateTime.now().isBefore(_nextEligibleAt)) {
      _droppedFrames++;
      return;
    }
    _isProcessing = true;
    unawaited(_processFrame(image));
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
      _nextEligibleAt = DateTime.now().add(_minimumInferenceGap);
    }
  }

  void resetTelemetry() {
    _droppedFrames = 0;
  }

  void pause() {
    _isPaused = true;
  }

  void resume() {
    if (_isDisposed) return;
    _isPaused = false;
    _nextEligibleAt = DateTime.now();
  }

  void dispose() {
    _isDisposed = true;
    _detectionController.close();
  }
}
