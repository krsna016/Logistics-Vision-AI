import 'package:flutter/material.dart';

class VinayakLogoPainter extends CustomPainter {
  final Color primaryBlue;
  final Color lightBlue;
  final Color silver;

  VinayakLogoPainter({
    required this.primaryBlue,
    required this.lightBlue,
    required this.silver,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Draw Outer Blue Diamond (divided into left and right gradient halves)
    // Applied a 12% safe padding bounds to prevent clipping at the canvas edges.
    final Paint leftBluePaint = Paint()
      ..shader = LinearGradient(
        colors: [lightBlue, primaryBlue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w / 2, h));

    final Paint rightBluePaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryBlue, primaryBlue.withBlue(130)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(w / 2, 0, w / 2, h));

    // Outer Left half
    final Path leftHalf = Path()
      ..moveTo(w * 0.5, h * 0.08)
      ..lineTo(w * 0.14, h * 0.58)
      ..lineTo(w * 0.5, h * 0.88)
      ..close();
    canvas.drawPath(leftHalf, leftBluePaint);

    // Outer Right half
    final Path rightHalf = Path()
      ..moveTo(w * 0.5, h * 0.08)
      ..lineTo(w * 0.86, h * 0.58)
      ..lineTo(w * 0.5, h * 0.88)
      ..close();
    canvas.drawPath(rightHalf, rightBluePaint);

    // 2. Silver metallic wings (layered paths forming folds with a distinct center gap)
    final Paint silverWingPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white, silver, Colors.grey.shade600],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final Paint silverFoldPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white, silver],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Left Wing main bar (Ends before the center line to leave a gap)
    final Path leftWingBar = Path()
      ..moveTo(w * 0.34, h * 0.24)
      ..lineTo(w * 0.41, h * 0.24)
      ..lineTo(w * 0.46, h * 0.88)
      ..lineTo(w * 0.39, h * 0.88)
      ..close();
    canvas.drawPath(leftWingBar, silverWingPaint);

    // Left Wing bottom fold flap (flaring out to matching side corners)
    final Path leftBottomFlap = Path()
      ..moveTo(w * 0.39, h * 0.88)
      ..lineTo(w * 0.46, h * 0.88)
      ..lineTo(w * 0.14, h * 0.58)
      ..close();
    canvas.drawPath(leftBottomFlap, silverFoldPaint);

    // Right Wing main bar (Ends before the center line to leave a gap)
    final Path rightWingBar = Path()
      ..moveTo(w * 0.66, h * 0.24)
      ..lineTo(w * 0.59, h * 0.24)
      ..lineTo(w * 0.54, h * 0.88)
      ..lineTo(w * 0.61, h * 0.88)
      ..close();
    canvas.drawPath(rightWingBar, silverWingPaint);

    // Right Wing bottom fold flap
    final Path rightBottomFlap = Path()
      ..moveTo(w * 0.61, h * 0.88)
      ..lineTo(w * 0.54, h * 0.88)
      ..lineTo(w * 0.86, h * 0.58)
      ..close();
    canvas.drawPath(rightBottomFlap, silverFoldPaint);

    // Center divider highlight line passing through the gap
    final Paint centerLine = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(w * 0.5, h * 0.08), Offset(w * 0.5, h * 0.88), centerLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
