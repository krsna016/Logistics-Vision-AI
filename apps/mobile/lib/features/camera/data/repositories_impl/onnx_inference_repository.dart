import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';

import '../../../../core/ai_engine/inference_pipeline.dart';
import '../../../../core/ai_engine/manager/model_manager.dart';
import '../../../../core/ai_engine/models/ai_model.dart';
import '../../../../core/ai_engine/modules/detection_validator.dart';
import '../../../../core/ai_engine/modules/image_preprocessor.dart';
import '../../../../core/ai_engine/modules/performance_monitor.dart';
import '../../../../core/ai_engine/modules/postprocessor.dart';
import '../../../../core/ai_engine/modules/tracking_engine.dart';
import '../../domain/entities/detection.dart';
import '../../domain/entities/inference_telemetry.dart';
import '../../domain/repositories/inference_repository.dart';

class ONNXInferenceRepository implements InferenceRepository {
  late final InferencePipeline _pipeline;

  ONNXInferenceRepository() {
    _pipeline = InferencePipeline(
      modelManager: ModelManager(),
      preprocessor: ImagePreprocessor(),
      postprocessor: Postprocessor(),
      trackingEngine: TrackingEngine(),
      validator: DetectionValidator(),
      performanceMonitor: PerformanceMonitor(),
    );
  }

  @override
  Future<void> loadModel() async {
    await _pipeline.modelManager.loadModel(AIModel.modelB());
  }

  @override
  Future<List<Detection>> runInference(CameraImage image) async {
    return await _pipeline.run(image);
  }

  @override
  Future<List<Detection>> runGalleryInference(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return [];

    final image = img.bakeOrientation(decoded);
    final input = _pipeline.preprocessor.processRgbImage(image);
    final rawOutput = await _pipeline.modelManager.run(input);
    final decodedResults = _pipeline.postprocessor.process(
      rawOutput is List ? rawOutput.cast<dynamic>() : const [],
      imageWidth: image.width,
      imageHeight: image.height,
    );
    return _pipeline.validator.validate(decodedResults).map((d) {
      return Detection(
        id: d.id,
        label: d.label,
        confidence: d.confidence,
        boundingBox: BoundingBox(
          xMin: d.xMin,
          yMin: d.yMin,
          xMax: d.xMax,
          yMax: d.yMax,
        ),
      );
    }).toList(growable: false);
  }

  @override
  void setDebugMode(bool enabled) {
    // The current pipeline has no debug-only inference branch. Keep the API
    // for the telemetry overlay without retaining unused mutable state.
  }

  @override
  InferenceTelemetry getTelemetry() {
    final metrics = _pipeline.performanceMonitor.getMetrics();

    return InferenceTelemetry(
      fps: metrics.fps,
      inferenceTimeMs: metrics.averageInferenceTime,
      totalDetectionsCount: metrics.totalDetections,
      droppedFramesCount: 0,
    );
  }

  @override
  Future<void> release() async {
    await _pipeline.modelManager.unloadModel();
  }
}
