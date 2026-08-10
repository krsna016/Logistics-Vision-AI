import 'package:flutter/material.dart';
import '../../domain/entities/detection.dart';

class DetectionPainter extends CustomPainter {
  final List<Detection> detections;
  final Size cameraSize;
  final BoxFit fit;
  final String? selectedId;
  final bool showLabels;
  final bool showNumbers;

  DetectionPainter({
    required this.detections,
    required this.cameraSize,
    this.fit = BoxFit.cover,
    this.selectedId,
    this.showLabels = true,
    this.showNumbers = false,
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

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.65
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var detectionIndex = 0;
        detectionIndex < detections.length;
        detectionIndex++) {
      final detection = detections[detectionIndex];
      final isSelected = detection.id == selectedId;
      final isManual = detection.metadata['manuallyAdded'] == true;
      final color = isManual
          ? const Color(0xFF34D399)
          : _palette[detection.id.hashCode.abs() % _palette.length];

      outlinePaint.color = isSelected ? Colors.white : color;
      outlinePaint.strokeWidth = isSelected ? 2.7 : 1.65;
      fillPaint.color = color.withValues(alpha: isSelected ? 0.16 : 0.09);

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
      if (detection.polygon.length >= 3) {
        final path = Path();
        for (var i = 0; i < detection.polygon.length; i++) {
          final point = detection.polygon[i];
          if (point.length < 2) continue;
          final px = point[0] * cameraSize.width * scale + dx;
          final py = point[1] * cameraSize.height * scale + dy;
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, outlinePaint);
      } else {
        final rounded = RRect.fromRectAndRadius(rect, const Radius.circular(3));
        canvas.drawRRect(rounded, fillPaint);
        canvas.drawRRect(rounded, outlinePaint);
      }

      if (showNumbers) {
        _drawNumberBadge(
          canvas,
          textPainter,
          rect.topLeft + const Offset(2, 2),
          isManual ? '+' : '${detectionIndex + 1}',
          color,
        );
      }

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
          backgroundColor:
              isSelected ? Colors.yellow : color.withValues(alpha: 0.85),
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
        oldDelegate.showLabels != showLabels ||
        oldDelegate.showNumbers != showNumbers;
  }

  void _drawNumberBadge(Canvas canvas, TextPainter painter, Offset anchor,
      String value, Color color) {
    painter.text = TextSpan(
      text: value,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9,
        height: 1,
        fontWeight: FontWeight.w800,
      ),
    );
    painter.layout();
    final badgeSize = Size(painter.width + 7, 16);
    final badge = RRect.fromRectAndRadius(
      anchor & badgeSize,
      const Radius.circular(8),
    );
    canvas.drawRRect(badge, Paint()..color = const Color(0xDD07131C));
    canvas.drawRRect(
      badge,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
    painter.paint(
        canvas, anchor + Offset((badgeSize.width - painter.width) / 2, 3));
  }

  static const _palette = <Color>[
    Color(0xFF2DD4BF),
    Color(0xFF38BDF8),
    Color(0xFFFBBF24),
    Color(0xFFC084FC),
    Color(0xFFFB7185),
  ];
}
