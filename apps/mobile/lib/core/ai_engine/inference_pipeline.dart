import 'package:camera/camera.dart';
import 'dart:math';

import 'manager/model_manager.dart';
import 'modules/image_preprocessor.dart';
import 'modules/postprocessor.dart';
import 'modules/tracking_engine.dart';
import 'modules/detection_validator.dart';
import 'modules/performance_monitor.dart';
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

  /// Executes the full modular pipeline
  Future<List<Detection>> run(CameraImage image) async {
    if (modelManager.activeModel == null) return [];

    final prepStart = DateTime.now();
    
    // 1. Preprocessing
    final tensorInput = preprocessor.process(image);
    
    final infStart = DateTime.now();
    
    // 2. ONNX Inference (Mocked via edge gradients for now to simulate ONNX output)
    final rawOutput = _runSimulatedOnnxInference(image);
    
    final postStart = DateTime.now();

    // 3. Postprocessing
    // Normally we pass rawOutput tensor to postprocessor. 
    // Here we just pass the mocked list directly.
    final List<DetectionResult> postProcessed = postprocessor.process(
      [], 
      imageWidth: image.width, 
      imageHeight: image.height
    ).isEmpty ? rawOutput : []; // Mock bypass

    // 4. Validation
    final validated = validator.validate(postProcessed.isEmpty ? rawOutput : postProcessed);

    // 5. Tracking Engine
    final tracked = trackingEngine.update(validated);
    
    final postEnd = DateTime.now();

    // 6. Record Metrics
    performanceMonitor.recordFrame(
      infStart.difference(prepStart).inMicroseconds / 1000.0,
      postStart.difference(infStart).inMicroseconds / 1000.0,
      postEnd.difference(postStart).inMicroseconds / 1000.0,
      tracked.length,
    );

    // 7. Map back to domain entities
    return tracked.map((d) => Detection(
      id: d.id,
      label: d.label,
      confidence: d.confidence,
      boundingBox: BoundingBox(
        xMin: d.xMin,
        yMin: d.yMin,
        xMax: d.xMax,
        yMax: d.yMax,
      ),
    )).toList();
  }

  // Temporary mock of the C++ ONNX runtime using edge gradients from original code
  List<DetectionResult> _runSimulatedOnnxInference(CameraImage image) {
    if (image.planes.isEmpty) return [];

    final plane = image.planes[0];
    final bytes = plane.bytes;
    final int width = image.width;
    final int height = image.height;
    final int bytesPerRow = plane.bytesPerRow;

    const int cols = 8;
    const int rows = 10;
    
    final int cellWidth = width ~/ cols;
    final int cellHeight = height ~/ rows;
    final List<DetectionResult> detections = [];

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        int edgeGradientSum = 0;
        int samplesCount = 0;

        final startX = c * cellWidth;
        final startY = r * cellHeight;

        for (int y = startY + 4; y < startY + cellHeight - 4; y += 8) {
          for (int x = startX + 4; x < startX + cellWidth - 4; x += 8) {
            if (x >= width - 1 || y >= height - 1) continue;

            final int idx = y * bytesPerRow + x;
            final int idxRight = y * bytesPerRow + (x + 1);
            final int idxDown = (y + 1) * bytesPerRow + x;

            final int currentVal = bytes[idx];
            final int dx = (bytes[idxRight] - currentVal).abs();
            final int dy = (bytes[idxDown] - currentVal).abs();

            edgeGradientSum += dx + dy;
            samplesCount++;
          }
        }

        final double averageGradient = samplesCount > 0 ? edgeGradientSum / samplesCount : 0.0;

        if (averageGradient > 8.5) {
          detections.add(
            DetectionResult(
              id: 'carton_${r}_${c}',
              xMin: c / cols,
              yMin: r / rows,
              xMax: (c + 1) / cols,
              yMax: (r + 1) / rows,
              label: 'carton',
              confidence: min(0.99, 0.70 + (averageGradient / 100.0)),
            ),
          );
        }
      }
    }
    return detections;
  }
}
