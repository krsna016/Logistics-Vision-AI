import 'package:flutter/material.dart';
import '../../domain/entities/detection.dart';

/// Returns a display-only verification order: rows from top to bottom and
/// cartons inside each row from left to right. Detection IDs and model output
/// order stay untouched, so editing and inference behaviour are unaffected.
List<Detection> orderDetectionsForVerification(List<Detection> detections) {
  if (detections.length < 2) return List<Detection>.of(detections);

  final pending = List<Detection>.of(detections)
    ..sort((a, b) {
      final byY = _centerY(a).compareTo(_centerY(b));
      return byY != 0 ? byY : _centerX(a).compareTo(_centerX(b));
    });
  final rows = <_DetectionRow>[];

  for (final detection in pending) {
    _DetectionRow? bestRow;
    var bestDistance = double.infinity;
    final centerY = _centerY(detection);
    final height = _height(detection);

    for (final row in rows) {
      final distance = (centerY - row.centerY).abs();
      // Half the typical carton height reliably joins perspective-skewed
      // cartons in one visual row without merging adjacent stacked rows.
      final tolerance =
          ((height + row.averageHeight) * 0.25).clamp(0.018, 0.12);
      if (distance <= tolerance && distance < bestDistance) {
        bestRow = row;
        bestDistance = distance;
      }
    }

    if (bestRow == null) {
      rows.add(_DetectionRow(detection));
    } else {
      bestRow.add(detection);
    }
  }

  rows.sort((a, b) => a.centerY.compareTo(b.centerY));
  return <Detection>[
    for (final row in rows)
      ...(row.detections..sort((a, b) => _centerX(a).compareTo(_centerX(b)))),
  ];
}

double _centerX(Detection detection) =>
    (detection.boundingBox.xMin + detection.boundingBox.xMax) / 2;

double _centerY(Detection detection) =>
    (detection.boundingBox.yMin + detection.boundingBox.yMax) / 2;

double _height(Detection detection) =>
    (detection.boundingBox.yMax - detection.boundingBox.yMin).abs();

class _DetectionRow {
  final List<Detection> detections = [];
  double _centerYTotal = 0;
  double _heightTotal = 0;

  _DetectionRow(Detection detection) {
    add(detection);
  }

  double get centerY => _centerYTotal / detections.length;
  double get averageHeight => _heightTotal / detections.length;

  void add(Detection detection) {
    detections.add(detection);
    _centerYTotal += _centerY(detection);
    _heightTotal += _height(detection);
  }
}

class DetectionPainter extends CustomPainter {
  final List<Detection> detections;
  final Size cameraSize;
  final BoxFit fit;
  final String? selectedId;
  final bool showLabels;
  final bool showNumbers;
  final bool showOutlines;
  final bool useDarkPalette;

  DetectionPainter({
    required this.detections,
    required this.cameraSize,
    this.fit = BoxFit.cover,
    this.selectedId,
    this.showLabels = true,
    this.showNumbers = false,
    this.showOutlines = true,
    this.useDarkPalette = false,
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
    final verificationNumbers = showNumbers
        ? <String, int>{
            for (final entry
                in orderDetectionsForVerification(detections).asMap().entries)
              entry.value.id: entry.key + 1,
          }
        : const <String, int>{};

    for (var detectionIndex = 0;
        detectionIndex < detections.length;
        detectionIndex++) {
      final detection = detections[detectionIndex];
      final isSelected = detection.id == selectedId;
      final isManual = detection.metadata['manuallyAdded'] == true;
      final palette = useDarkPalette ? _darkPalette : _palette;
      final color = isManual
          ? (useDarkPalette ? const Color(0xFF047857) : const Color(0xFF34D399))
          : palette[detection.id.hashCode.abs() % palette.length];

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
      if (showOutlines) {
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
          final rounded =
              RRect.fromRectAndRadius(rect, const Radius.circular(3));
          canvas.drawRRect(rounded, fillPaint);
          canvas.drawRRect(rounded, outlinePaint);
        }
      }

      if (showNumbers) {
        _drawNumberBadge(
          canvas,
          textPainter,
          rect.topLeft + const Offset(2, 2),
          '${verificationNumbers[detection.id] ?? detectionIndex + 1}',
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
        oldDelegate.showNumbers != showNumbers ||
        oldDelegate.showOutlines != showOutlines ||
        oldDelegate.useDarkPalette != useDarkPalette;
  }

  void _drawNumberBadge(Canvas canvas, TextPainter painter, Offset anchor,
      String value, Color color) {
    painter.text = TextSpan(
      text: value,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 8.3,
        height: 1,
        fontWeight: FontWeight.w800,
      ),
    );
    painter.layout();
    final badgeSize = Size(painter.width + 6, 14.5);
    final badge = RRect.fromRectAndRadius(
      anchor & badgeSize,
      const Radius.circular(7.25),
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
        canvas, anchor + Offset((badgeSize.width - painter.width) / 2, 2.7));
  }

  static const _palette = <Color>[
    Color(0xFF2DD4BF),
    Color(0xFF38BDF8),
    Color(0xFFFBBF24),
    Color(0xFFC084FC),
    Color(0xFFFB7185),
  ];

  static const _darkPalette = <Color>[
    Color(0xFF00695C),
    Color(0xFF0369A1),
    Color(0xFFB45309),
    Color(0xFF7E22CE),
    Color(0xFFBE123C),
    Color(0xFF166534),
  ];
}
