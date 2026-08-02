import 'package:flutter/material.dart';
import '../../domain/entities/detection.dart';
import 'detection_painter.dart';

class DetectionOverlayWidget extends StatelessWidget {
  final List<Detection> detections;
  final List<Detection>? hitTestDetections;
  final Size cameraSize;
  final BoxFit fit;
  final String? selectedId;
  final bool showLabels;
  final ValueChanged<Detection>? onDetectionTapped;
  final ValueChanged<Offset>? onEmptyAreaTapped;

  const DetectionOverlayWidget({
    super.key,
    required this.detections,
    this.hitTestDetections,
    required this.cameraSize,
    this.fit = BoxFit.cover,
    this.selectedId,
    this.showLabels = true,
    this.onDetectionTapped,
    this.onEmptyAreaTapped,
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
          showLabels: showLabels,
        ),
        child: Container(),
      ),
    );
  }

  void _handleTap(BuildContext context, Offset localPosition) {
    if (onDetectionTapped == null && onEmptyAreaTapped == null) return;

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

    // Prefer visible detections so a hidden box cannot steal taps from a
    // visible box beneath it. Hidden detections remain available afterwards
    // so tapping a hidden area can restore that box.
    final visibleIds = detections.map((detection) => detection.id).toSet();
    final tappableDetections = <Detection>[
      ...detections,
      ...?hitTestDetections
          ?.where((detection) => !visibleIds.contains(detection.id)),
    ];
    for (final detection in tappableDetections) {
      final double left =
          detection.boundingBox.xMin * cameraSize.width * scale + dx;
      final double top =
          detection.boundingBox.yMin * cameraSize.height * scale + dy;
      final double right =
          detection.boundingBox.xMax * cameraSize.width * scale + dx;
      final double bottom =
          detection.boundingBox.yMax * cameraSize.height * scale + dy;

      final rect = Rect.fromLTRB(left, top, right, bottom);
      if (rect.contains(localPosition)) {
        onDetectionTapped?.call(detection);
        break;
      }
    }

    if (onEmptyAreaTapped != null &&
        !tappableDetections.any((detection) {
          final left =
              detection.boundingBox.xMin * cameraSize.width * scale + dx;
          final top =
              detection.boundingBox.yMin * cameraSize.height * scale + dy;
          final right =
              detection.boundingBox.xMax * cameraSize.width * scale + dx;
          final bottom =
              detection.boundingBox.yMax * cameraSize.height * scale + dy;
          return Rect.fromLTRB(left, top, right, bottom)
              .contains(localPosition);
        })) {
      final normalized = Offset(
        ((localPosition.dx - dx) / (cameraSize.width * scale)).clamp(0.0, 1.0),
        ((localPosition.dy - dy) / (cameraSize.height * scale)).clamp(0.0, 1.0),
      );
      onEmptyAreaTapped!(normalized);
    }
  }
}
