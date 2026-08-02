import 'package:flutter/material.dart';
import '../../domain/entities/detection.dart';

class DetectionPainter extends CustomPainter {
  final List<Detection> detections;
  final Size cameraSize;
  final BoxFit fit;
  final String? selectedId;
  final bool showLabels;

  DetectionPainter({
    required this.detections,
    required this.cameraSize,
    this.fit = BoxFit.cover,
    this.selectedId,
    this.showLabels = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (detections.isEmpty || cameraSize.width == 0 || cameraSize.height == 0) {
      return;
    }

    // Calculate scaling metrics according to the BoxFit mode
    final double scaleX = size.width / cameraSize.width;
    final double scaleY = size.height / cameraSize.height;

    double scale;
    double dx = 0;
    double dy = 0;

    if (fit == BoxFit.cover) {
      scale = scaleX > scaleY ? scaleX : scaleY;
      dx = (size.width - cameraSize.width * scale) / 2;
      dy = (size.height - cameraSize.height * scale) / 2;
    } else {
      // BoxFit.contain configuration
      scale = scaleX < scaleY ? scaleX : scaleY;
      dx = (size.width - cameraSize.width * scale) / 2;
      dy = (size.height - cameraSize.height * scale) / 2;
    }

    final boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (final detection in detections) {
      final isSelected = detection.id == selectedId;

      // Configure drawing color based on selection states
      boxPaint.color = isSelected ? Colors.yellow : detection.color;
      boxPaint.strokeWidth = isSelected ? 5.0 : 3.0;

      // Map normalized coordinates to scaled canvas positions
      final double left =
          detection.boundingBox.xMin * cameraSize.width * scale + dx;
      final double top =
          detection.boundingBox.yMin * cameraSize.height * scale + dy;
      final double right =
          detection.boundingBox.xMax * cameraSize.width * scale + dx;
      final double bottom =
          detection.boundingBox.yMax * cameraSize.height * scale + dy;

      final rect = Rect.fromLTRB(left, top, right, bottom);
      canvas.drawRect(rect, boxPaint);

      if (!showLabels) continue;

      // Render Label banner overlay
      final confidencePct = (detection.confidence * 100).toStringAsFixed(0);
      final labelText = '${detection.label} ($confidencePct%)';

      textPainter.text = TextSpan(
        text: labelText,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          backgroundColor: isSelected
              ? Colors.yellow
              : detection.color.withValues(alpha: 0.85),
        ),
      );

      textPainter.layout();
      // Draw label slightly above the bounding box
      textPainter.paint(canvas, Offset(rect.left, rect.top - 16));
    }
  }

  @override
  bool shouldRepaint(covariant DetectionPainter oldDelegate) {
    return oldDelegate.detections != detections ||
        oldDelegate.cameraSize != cameraSize ||
        oldDelegate.fit != fit ||
        oldDelegate.selectedId != selectedId ||
        oldDelegate.showLabels != showLabels;
  }
}
