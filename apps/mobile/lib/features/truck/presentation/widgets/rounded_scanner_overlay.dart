import 'package:flutter/material.dart';

/// Dims the camera outside a centered, rounded scanning window.
class RoundedScannerOverlay extends StatelessWidget {
  final double widthFactor;
  final double cornerRadius;

  const RoundedScannerOverlay({
    super.key,
    this.widthFactor = 0.76,
    this.cornerRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _RoundedScannerOverlayPainter(
          widthFactor: widthFactor,
          cornerRadius: cornerRadius,
        ),
      ),
    );
  }
}

class _RoundedScannerOverlayPainter extends CustomPainter {
  final double widthFactor;
  final double cornerRadius;

  const _RoundedScannerOverlayPainter({
    required this.widthFactor,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final frameSide = (size.width * widthFactor).clamp(
      180.0,
      size.height * 0.58,
    );
    final frame = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: frameSide,
      height: frameSide,
    );
    final frameRRect = RRect.fromRectAndRadius(
      frame,
      Radius.circular(cornerRadius),
    );

    final mask = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(frameRRect);
    canvas.drawPath(
      mask,
      Paint()..color = Colors.black.withValues(alpha: 0.5),
    );
  }

  @override
  bool shouldRepaint(covariant _RoundedScannerOverlayPainter oldDelegate) {
    return oldDelegate.widthFactor != widthFactor ||
        oldDelegate.cornerRadius != cornerRadius;
  }
}
