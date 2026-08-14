import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/detection.dart';
import 'detection_painter.dart';

class DetectionOverlayWidget extends StatelessWidget {
  final List<Detection> detections;
  final List<Detection>? hitTestDetections;
  final Size cameraSize;
  final BoxFit fit;
  final String? selectedId;
  final bool showLabels;
  final bool showNumbers;
  final bool showOutlines;
  final bool useDarkPalette;
  final ValueChanged<Detection>? onDetectionTapped;
  final ValueChanged<Detection>? onDetectionLongPressed;
  final ValueChanged<Offset>? onEmptyAreaTapped;
  final ValueChanged<Rect>? onBoxDrawn;

  const DetectionOverlayWidget({
    super.key,
    required this.detections,
    this.hitTestDetections,
    required this.cameraSize,
    this.fit = BoxFit.cover,
    this.selectedId,
    this.showLabels = true,
    this.showNumbers = false,
    this.showOutlines = true,
    this.useDarkPalette = false,
    this.onDetectionTapped,
    this.onDetectionLongPressed,
    this.onEmptyAreaTapped,
    this.onBoxDrawn,
  });

  @override
  Widget build(BuildContext context) {
    Offset? dragStart;
    Rect? normalizedDragRect;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapUp: (details) => _handleTap(context, details.localPosition),
      onLongPressStart: onDetectionLongPressed == null
          ? null
          : (details) => _handleLongPress(
                context,
                details.localPosition,
              ),
      onDoubleTapDown: onDetectionLongPressed == null
          ? null
          : (details) => _handleRemovalGesture(
                context,
                details.localPosition,
              ),
      onPanStart: onBoxDrawn == null
          ? null
          : (details) => dragStart = _toNormalized(
                context,
                details.localPosition,
              ),
      onPanEnd: onBoxDrawn == null
          ? null
          : (_) {
              final rect = normalizedDragRect;
              normalizedDragRect = null;
              if (rect != null && rect.width >= 0.015 && rect.height >= 0.015) {
                onBoxDrawn!(rect);
              }
            },
      onPanUpdate: onBoxDrawn == null
          ? null
          : (details) {
              final start = dragStart;
              if (start == null) return;
              final current = _toNormalized(context, details.localPosition);
              normalizedDragRect = Rect.fromLTRB(
                start.dx < current.dx ? start.dx : current.dx,
                start.dy < current.dy ? start.dy : current.dy,
                start.dx > current.dx ? start.dx : current.dx,
                start.dy > current.dy ? start.dy : current.dy,
              );
            },
      child: CustomPaint(
        painter: DetectionPainter(
          detections: detections,
          cameraSize: cameraSize,
          fit: fit,
          selectedId: selectedId,
          showLabels: showLabels,
          showNumbers: showNumbers,
          showOutlines: showOutlines,
          useDarkPalette: useDarkPalette,
        ),
        child: Container(),
      ),
    );
  }

  Offset _toNormalized(BuildContext context, Offset localPosition) {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final scaleX = size.width / cameraSize.width;
    final scaleY = size.height / cameraSize.height;
    final scale = fit == BoxFit.cover
        ? (scaleX > scaleY ? scaleX : scaleY)
        : (scaleX < scaleY ? scaleX : scaleY);
    final dx = (size.width - cameraSize.width * scale) / 2;
    final dy = (size.height - cameraSize.height * scale) / 2;
    return Offset(
      ((localPosition.dx - dx) / (cameraSize.width * scale)).clamp(0.0, 1.0),
      ((localPosition.dy - dy) / (cameraSize.height * scale)).clamp(0.0, 1.0),
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

    final normalized = Offset(
      ((localPosition.dx - dx) / (cameraSize.width * scale)).clamp(0.0, 1.0),
      ((localPosition.dy - dy) / (cameraSize.height * scale)).clamp(0.0, 1.0),
    );

    // A normal tap never removes a visible carton. This is important for
    // compact layers where neighbouring bounding rectangles overlap.
    final visibleIds = detections.map((detection) => detection.id).toSet();
    final visibleHit = _closestHit(detections, normalized);
    if (visibleHit != null) {
      onDetectionTapped?.call(visibleHit);
      return;
    }

    final hidden = hitTestDetections
            ?.where((detection) => !visibleIds.contains(detection.id))
            .toList(growable: false) ??
        const <Detection>[];
    final hiddenHit = _closestHit(hidden, normalized);
    if (hiddenHit != null) {
      onDetectionTapped?.call(hiddenHit);
      return;
    }

    onEmptyAreaTapped?.call(normalized);
  }

  void _handleLongPress(BuildContext context, Offset localPosition) {
    _handleRemovalGesture(context, localPosition);
  }

  void _handleRemovalGesture(BuildContext context, Offset localPosition) {
    final normalized = _toNormalized(context, localPosition);
    final hit = _closestHit(detections, normalized, allowBoxFallback: true);
    if (hit != null) {
      HapticFeedback.mediumImpact();
      onDetectionLongPressed?.call(hit);
    }
  }

  Detection? _closestHit(
    List<Detection> candidates,
    Offset point, {
    bool allowBoxFallback = false,
  }) {
    bool preciseHit(Detection detection) {
      if (detection.polygon.length >= 3) {
        final path = Path();
        for (var index = 0; index < detection.polygon.length; index++) {
          final vertex = detection.polygon[index];
          if (vertex.length < 2) continue;
          final offset = Offset(vertex[0], vertex[1]);
          if (index == 0) {
            path.moveTo(offset.dx, offset.dy);
          } else {
            path.lineTo(offset.dx, offset.dy);
          }
        }
        path.close();
        return path.contains(point);
      }
      final box = detection.boundingBox;
      return Rect.fromLTRB(box.xMin, box.yMin, box.xMax, box.yMax)
          .contains(point);
    }

    var hits = candidates.where(preciseHit).toList(growable: false);
    if (hits.isEmpty && allowBoxFallback) {
      hits = candidates.where((detection) {
        final box = detection.boundingBox;
        return Rect.fromLTRB(box.xMin, box.yMin, box.xMax, box.yMax)
            .contains(point);
      }).toList(growable: false);
    }
    if (hits.isEmpty) return null;
    hits.sort((first, second) {
      double distance(Detection detection) {
        final box = detection.boundingBox;
        final center = Offset(
          (box.xMin + box.xMax) / 2,
          (box.yMin + box.yMax) / 2,
        );
        return (center - point).distanceSquared;
      }

      return distance(first).compareTo(distance(second));
    });
    return hits.first;
  }
}
