import 'dart:typed_data';

import 'package:camera/camera.dart';

import 'manager/model_manager.dart';
import 'modules/detection_validator.dart';
import 'modules/image_preprocessor.dart';
import 'modules/performance_monitor.dart';
import 'modules/postprocessor.dart';
import 'modules/tracking_engine.dart';
import 'models/detection_result.dart';
import '../../../features/camera/domain/entities/detection.dart';

class InferencePipeline {
  final ModelManager modelManager;
  final ImagePreprocessor preprocessor;
  final Postprocessor postprocessor;
  final TrackingEngine trackingEngine;
  final DetectionValidator validator;
  final PerformanceMonitor performanceMonitor;

  InferencePipeline({
    required this.modelManager,
    required this.preprocessor,
    required this.postprocessor,
    required this.trackingEngine,
    required this.validator,
    required this.performanceMonitor,
  });

  Future<List<Detection>> run(CameraImage image) async {
    if (modelManager.activeModel == null) return [];

    final prepStart = DateTime.now();
    final Float32List tensorInput = await preprocessor.processAsync(image);
    final infStart = DateTime.now();
    final rawOutput = await modelManager.run(tensorInput);
    final postStart = DateTime.now();

    final List<DetectionResult> decoded = postprocessor.process(
      rawOutput is List ? rawOutput.cast<dynamic>() : const [],
      imageWidth: image.width,
      imageHeight: image.height,
      // Polygon reconstruction is substantially more expensive than carton
      // counting. Live preview uses stable boxes; the captured final frame
      // still receives the full segmentation masks.
      decodeMasks: false,
      // Raw Android camera frames commonly arrive in landscape sensor
      // coordinates while the visible preview is portrait. File-based
      // Gallery/capture inference never enables this sensor-only transform.
      rotateLandscapeSensorToPortrait: image.width > image.height,
    );
    final validated = validator.validate(decoded);
    final tracked = trackingEngine.update(validated);
    final postEnd = DateTime.now();

    performanceMonitor.recordFrame(
      infStart.difference(prepStart).inMicroseconds / 1000.0,
      postStart.difference(infStart).inMicroseconds / 1000.0,
      postEnd.difference(postStart).inMicroseconds / 1000.0,
      tracked.length,
    );

    return tracked
        .map((d) => Detection(
              id: d.id,
              label: d.label,
              confidence: d.confidence,
              boundingBox: BoundingBox(
                xMin: d.xMin,
                yMin: d.yMin,
                xMax: d.xMax,
                yMax: d.yMax,
              ),
              polygon: d.polygon,
            ))
        .toList();
  }
}
