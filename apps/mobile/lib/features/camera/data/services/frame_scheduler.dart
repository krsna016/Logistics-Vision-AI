import 'dart:async';
import 'package:camera/camera.dart';
import '../../domain/entities/detection.dart';
import '../../domain/repositories/inference_repository.dart';
import '../../../../utils/logger.dart';

class FrameScheduler {
  final InferenceRepository _repository;
  bool _isProcessing = false;
  CameraImage? _nextFrame;
  int _droppedFrames = 0;
  
  final _detectionController = StreamController<List<Detection>>.broadcast();

  FrameScheduler(this._repository);

  Stream<List<Detection>> get detectionsStream => _detectionController.stream;
  int get droppedFramesCount => _droppedFrames;

  /// Schedule a camera frame for processing. Drops intermediate frames if busy.
  void scheduleFrame(CameraImage image) {
    if (_isProcessing) {
      // Overwrite the previous pending frame to process only the latest captured state.
      if (_nextFrame != null) {
        _droppedFrames++;
      }
      _nextFrame = image;
      return;
    }

    _isProcessing = true;
    _processFrame(image);
  }

  Future<void> _processFrame(CameraImage image) async {
    try {
      final results = await _repository.runInference(image);
      if (!_detectionController.isClosed) {
        _detectionController.add(results);
      }
    } catch (e, stack) {
      AppLogger.error('Inference pipeline execution error in scheduler', e, stack);
    } finally {
      _isProcessing = false;
      
      // If a newer frame arrived while we were busy, execute it now.
      final next = _nextFrame;
      if (next != null) {
        _nextFrame = null;
        scheduleFrame(next);
      }
    }
  }

  void resetTelemetry() {
    _droppedFrames = 0;
  }

  void dispose() {
    _detectionController.close();
  }
}
