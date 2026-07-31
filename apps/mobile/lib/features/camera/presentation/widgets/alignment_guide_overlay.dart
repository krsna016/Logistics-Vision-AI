import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import 'dart:ui' as ui;
import 'dart:math';

class AlignmentGuideOverlay extends StatefulWidget {
  final bool isVisible;

  const AlignmentGuideOverlay({super.key, this.isVisible = true});

  @override
  State<AlignmentGuideOverlay> createState() => _AlignmentGuideOverlayState();
}

class _AlignmentGuideOverlayState extends State<AlignmentGuideOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: widget.isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _AlignmentGuidePainter(_controller),
                ),
              ),
              Positioned(
                bottom: 80, // rough position below center rect
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Align front layer inside the guide',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AlignmentGuidePainter extends CustomPainter {
  final Animation<double> animation;
  _AlignmentGuidePainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width * 0.82;
    final height = size.height * 0.52;
    final rect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: width,
        height: height);

    // Semi-transparent fill
    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);

    // Dashed border
    final borderPaint = Paint()
      ..color = const Color(0xFF1565C0).withOpacity(0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw dashed rectangle using path metrics
    final dashWidth = 8.0;
    final dashSpace = 4.0;
    double distance = 0;
    Path path = Path()..addRect(rect);
    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        final length = min(dashWidth, pathMetric.length - distance);
        canvas.drawPath(
            pathMetric.extractPath(distance, distance + length), borderPaint);
        distance += dashWidth + dashSpace;
      }
      distance = 0;
    }

    // Corner brackets
    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const double bracketLen = 20;

    // Top-left
    canvas.drawPath(
        Path()
          ..moveTo(rect.left, rect.top + bracketLen)
          ..lineTo(rect.left, rect.top)
          ..lineTo(rect.left + bracketLen, rect.top),
        cornerPaint);

    // Top-right
    canvas.drawPath(
        Path()
          ..moveTo(rect.right - bracketLen, rect.top)
          ..lineTo(rect.right, rect.top)
          ..lineTo(rect.right, rect.top + bracketLen),
        cornerPaint);

    // Bottom-right
    canvas.drawPath(
        Path()
          ..moveTo(rect.right, rect.bottom - bracketLen)
          ..lineTo(rect.right, rect.bottom)
          ..lineTo(rect.right - bracketLen, rect.bottom),
        cornerPaint);

    // Bottom-left
    canvas.drawPath(
        Path()
          ..moveTo(rect.left + bracketLen, rect.bottom)
          ..lineTo(rect.left, rect.bottom)
          ..lineTo(rect.left, rect.bottom - bracketLen),
        cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
