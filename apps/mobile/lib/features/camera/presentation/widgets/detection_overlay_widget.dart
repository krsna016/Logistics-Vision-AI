import 'package:flutter/material.dart';
import '../../domain/entities/detection.dart';
import 'detection_painter.dart';

class DetectionOverlayWidget extends StatelessWidget {
  final List<Detection> detections;
  final Size cameraSize;
  final BoxFit fit;
  final String? selectedId;
  final ValueChanged<Detection>? onDetectionTapped;

  const DetectionOverlayWidget({
    super.key,
    required this.detections,
    required this.cameraSize,
    this.fit = BoxFit.cover,
    this.selectedId,
    this.onDetectionTapped,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) => _handleTap(context, details.localPosition),
      child: CustomPaint(
        painter: DetectionPainter(
          detections: detections,
          cameraSize: cameraSize,
          fit: fit,
          selectedId: selectedId,
        ),
        child: Container(),
      ),
    );
  }

  void _handleTap(BuildContext context, Offset localPosition) {
    if (onDetectionTapped == null || detections.isEmpty) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    // Replicate scale factors to locate coordinate collision
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
      scale = scaleX < scaleY ? scaleX : scaleY;
      dx = (size.width - cameraSize.width * scale) / 2;
      dy = (size.height - cameraSize.height * scale) / 2;
    }

    for (final detection in detections) {
      final double left = detection.boundingBox.xMin * cameraSize.width * scale + dx;
      final double top = detection.boundingBox.yMin * cameraSize.height * scale + dy;
      final double right = detection.boundingBox.xMax * cameraSize.width * scale + dx;
      final double bottom = detection.boundingBox.yMax * cameraSize.height * scale + dy;

      final rect = Rect.fromLTRB(left, top, right, bottom);
      if (rect.contains(localPosition)) {
        onDetectionTapped!(detection);
        break;
      }
    }
  }
}
