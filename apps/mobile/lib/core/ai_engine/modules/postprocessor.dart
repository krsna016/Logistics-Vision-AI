import '../models/detection_result.dart';
import 'dart:math' as math;

class Postprocessor {
  final double confidenceThreshold;
  final double iouThreshold;

  Postprocessor({
    this.confidenceThreshold = 0.5,
    this.iouThreshold = 0.45,
  });

  /// Processes raw ONNX output tensors into discrete bounding boxes.
  /// Applies Confidence Thresholding, NMS, Class Filtering, and Sorting.
  List<DetectionResult> process(List<dynamic> rawOutput,
      {required int imageWidth, required int imageHeight}) {
    if (rawOutput.isEmpty) return [];
    final batch = rawOutput.length == 1 ? rawOutput.first : rawOutput;
    if (batch is! List || batch.length < 5) return [];
    final channels = batch
        .map((channel) => (channel as List)
            .map((value) => (value as num).toDouble())
            .toList())
        .toList();
    final candidateCount = channels[0].length;
    final scale = math.min(640.0 / imageWidth, 640.0 / imageHeight);
    final resizedWidth = imageWidth * scale;
    final resizedHeight = imageHeight * scale;
    final padX = (640.0 - resizedWidth) / 2.0;
    final padY = (640.0 - resizedHeight) / 2.0;
    final candidates = <DetectionResult>[];

    for (var i = 0; i < candidateCount; i++) {
      final confidence = channels[4][i];
      if (confidence < confidenceThreshold) continue;
      // The exported YOLO ONNX graph returns center coordinates and size:
      // [centerX, centerY, width, height, confidence].
      final centerX = channels[0][i];
      final centerY = channels[1][i];
      final width = channels[2][i];
      final height = channels[3][i];
      final left =
          ((centerX - width / 2.0 - padX) / scale / imageWidth).clamp(0.0, 1.0);
      final top = ((centerY - height / 2.0 - padY) / scale / imageHeight)
          .clamp(0.0, 1.0);
      final right =
          ((centerX + width / 2.0 - padX) / scale / imageWidth).clamp(0.0, 1.0);
      final bottom = ((centerY + height / 2.0 - padY) / scale / imageHeight)
          .clamp(0.0, 1.0);
      if (right <= left || bottom <= top) continue;

      // Android can provide CameraImage frames in the sensor's landscape
      // orientation while CameraPreview displays them in portrait. Convert
      // the normalized box to display coordinates in that case. A clockwise
      // rotation maps (x, y) to (1-y, x).
      final displayLeft = imageWidth > imageHeight ? 1.0 - bottom : left;
      final displayTop = imageWidth > imageHeight ? left : top;
      final displayRight = imageWidth > imageHeight ? 1.0 - top : right;
      final displayBottom = imageWidth > imageHeight ? right : bottom;
      candidates.add(DetectionResult(
        id: 'carton_$i',
        label: 'carton',
        confidence: confidence,
        xMin: displayLeft,
        yMin: displayTop,
        xMax: displayRight,
        yMax: displayBottom,
      ));
    }

    candidates.sort((a, b) => b.confidence.compareTo(a.confidence));
    final selected = <DetectionResult>[];
    for (final candidate in candidates) {
      if (selected.every((other) => _iou(candidate, other) < iouThreshold)) {
        selected.add(candidate);
      }
    }
    return selected;
  }

  double _iou(DetectionResult a, DetectionResult b) {
    final left = math.max(a.xMin, b.xMin);
    final top = math.max(a.yMin, b.yMin);
    final right = math.min(a.xMax, b.xMax);
    final bottom = math.min(a.yMax, b.yMax);
    final intersection =
        math.max(0.0, right - left) * math.max(0.0, bottom - top);
    final areaA = (a.xMax - a.xMin) * (a.yMax - a.yMin);
    final areaB = (b.xMax - b.xMin) * (b.yMax - b.yMin);
    final union = areaA + areaB - intersection;
    return union <= 0 ? 0 : intersection / union;
  }
}
