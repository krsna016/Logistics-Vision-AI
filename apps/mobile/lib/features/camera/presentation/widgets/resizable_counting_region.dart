import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../layer/domain/entities/layer.dart';

/// A fast rectangular selection for still-photo carton counting. The dotted
/// edges resize the area and dragging inside moves the complete rectangle.
class ResizableCountingRegion extends StatefulWidget {
  final CountingRegion region;
  final ValueChanged<CountingRegion> onChanged;

  const ResizableCountingRegion({
    super.key,
    required this.region,
    required this.onChanged,
  });

  @override
  State<ResizableCountingRegion> createState() =>
      _ResizableCountingRegionState();
}

class _ResizableCountingRegionState extends State<ResizableCountingRegion> {
  static const _minimumEdge = 0.02;
  static const _minimumArea = 0.002;
  late CountingRegion _draftRegion;
  bool _isDragging = false;
  bool _showHint = true;
  Offset? _lastPointerPosition;
  Timer? _hintTimer;

  @override
  void initState() {
    super.initState();
    _draftRegion = widget.region;
    _hintTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showHint = false);
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ResizableCountingRegion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging && oldWidget.region != widget.region) {
      _draftRegion = widget.region;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final points = _pointsFor(size);
        final bounds = _bounds(points);
        return Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _RegionPainter(points)),
              ),
            ),
            if (bounds.width > 52 && bounds.height > 52)
              Positioned.fromRect(
                rect: bounds.deflate(24),
                child: Listener(
                  onPointerDown: _beginDrag,
                  onPointerMove: (event) => _move(event.delta, size),
                  onPointerUp: _commitDrag,
                  onPointerCancel: _cancelDrag,
                  child: const ColoredBox(color: Colors.transparent),
                ),
              ),
            for (final edge in _Edge.values) _edgeHandle(edge, points, size),
            for (final point in points) _cornerMarker(point),
            Positioned(
              left: 20,
              right: 20,
              top: 126,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _showHint ? 1 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Drag dotted edges to resize • Drag inside to move',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _beginDrag(PointerDownEvent event) {
    _isDragging = true;
    _lastPointerPosition = event.position;
  }

  void _commitDrag(PointerUpEvent event) {
    setState(() {
      _isDragging = false;
      _lastPointerPosition = null;
    });
    widget.onChanged(_draftRegion);
  }

  void _cancelDrag(PointerCancelEvent event) {
    setState(() {
      _isDragging = false;
      _lastPointerPosition = null;
      _draftRegion = widget.region;
    });
  }

  Offset _pointerDelta(PointerMoveEvent event) {
    final previous = _lastPointerPosition ?? event.position;
    _lastPointerPosition = event.position;
    return event.position - previous;
  }

  Widget _cornerMarker(Offset point) => Positioned(
        left: point.dx - 14,
        top: point.dy - 14,
        width: 28,
        height: 28,
        child: const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xD9000000),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF2196F3),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: 8, height: 8),
              ),
            ),
          ),
        ),
      );

  Widget _edgeHandle(_Edge edge, List<Offset> points, Size size) {
    final (start, end) = switch (edge) {
      _Edge.top => (points[0], points[1]),
      _Edge.right => (points[1], points[2]),
      _Edge.bottom => (points[3], points[2]),
      _Edge.left => (points[0], points[3]),
    };
    final vector = end - start;
    final length = vector.distance;
    final midpoint = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    return Positioned(
      left: midpoint.dx - length / 2,
      top: midpoint.dy - 24,
      width: length,
      height: 48,
      child: Transform.rotate(
        angle: math.atan2(vector.dy, vector.dx),
        alignment: Alignment.center,
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: _beginDrag,
          onPointerMove: (event) => _moveEdge(edge, _pointerDelta(event), size),
          onPointerUp: _commitDrag,
          onPointerCancel: _cancelDrag,
          child: const ColoredBox(color: Colors.transparent),
        ),
      ),
    );
  }

  List<Offset> _pointsFor(Size size) => [
        Offset(_draftRegion.topLeft.x * size.width,
            _draftRegion.topLeft.y * size.height),
        Offset(_draftRegion.topRight.x * size.width,
            _draftRegion.topRight.y * size.height),
        Offset(_draftRegion.bottomRight.x * size.width,
            _draftRegion.bottomRight.y * size.height),
        Offset(_draftRegion.bottomLeft.x * size.width,
            _draftRegion.bottomLeft.y * size.height),
      ];

  Rect _bounds(List<Offset> points) {
    final xs = points.map((point) => point.dx);
    final ys = points.map((point) => point.dy);
    return Rect.fromLTRB(
      xs.reduce(math.min),
      ys.reduce(math.min),
      xs.reduce(math.max),
      ys.reduce(math.max),
    );
  }

  void _move(Offset delta, Size size) {
    final points = _normalizedPoints();
    final dx = delta.dx / size.width;
    final dy = delta.dy / size.height;
    final minX = points.map((point) => point.x).reduce(math.min);
    final maxX = points.map((point) => point.x).reduce(math.max);
    final minY = points.map((point) => point.y).reduce(math.min);
    final maxY = points.map((point) => point.y).reduce(math.max);
    final boundedDx = dx.clamp(-minX, 1.0 - maxX);
    final boundedDy = dy.clamp(-minY, 1.0 - maxY);
    _updateDraft(_regionFromPoints([
      for (final point in points)
        CountingPoint(point.x + boundedDx, point.y + boundedDy),
    ]));
  }

  void _moveEdge(_Edge edge, Offset delta, Size size) {
    final points = _normalizedPoints();
    switch (edge) {
      case _Edge.top:
        final dy = delta.dy / size.height;
        points[0] = _shiftY(points[0], dy);
        points[1] = _shiftY(points[1], dy);
      case _Edge.right:
        final dx = delta.dx / size.width;
        points[1] = _shiftX(points[1], dx);
        points[2] = _shiftX(points[2], dx);
      case _Edge.bottom:
        final dy = delta.dy / size.height;
        points[2] = _shiftY(points[2], dy);
        points[3] = _shiftY(points[3], dy);
      case _Edge.left:
        final dx = delta.dx / size.width;
        points[0] = _shiftX(points[0], dx);
        points[3] = _shiftX(points[3], dx);
    }
    if (_isUsableQuad(points)) _updateDraft(_regionFromPoints(points));
  }

  CountingPoint _shiftX(CountingPoint point, double dx) =>
      CountingPoint((point.x + dx).clamp(0.0, 1.0), point.y);

  CountingPoint _shiftY(CountingPoint point, double dy) =>
      CountingPoint(point.x, (point.y + dy).clamp(0.0, 1.0));

  void _updateDraft(CountingRegion region) {
    setState(() => _draftRegion = region);
  }

  List<CountingPoint> _normalizedPoints() => [
        _draftRegion.topLeft,
        _draftRegion.topRight,
        _draftRegion.bottomRight,
        _draftRegion.bottomLeft,
      ];

  CountingRegion _regionFromPoints(List<CountingPoint> points) =>
      CountingRegion(
        topLeft: points[0],
        topRight: points[1],
        bottomRight: points[2],
        bottomLeft: points[3],
      );

  bool _isUsableQuad(List<CountingPoint> points) {
    final edges = <double>[];
    var signedAreaTwice = 0.0;
    var turnSign = 0.0;
    for (var index = 0; index < points.length; index++) {
      final current = points[index];
      final next = points[(index + 1) % points.length];
      final afterNext = points[(index + 2) % points.length];
      final dx = next.x - current.x;
      final dy = next.y - current.y;
      edges.add(math.sqrt(dx * dx + dy * dy));
      signedAreaTwice += current.x * next.y - next.x * current.y;
      final nextDx = afterNext.x - next.x;
      final nextDy = afterNext.y - next.y;
      final turn = dx * nextDy - dy * nextDx;
      if (turn.abs() < 0.0001) return false;
      if (turnSign == 0.0) {
        turnSign = turn.sign;
      } else if (turn.sign != turnSign) {
        return false;
      }
    }
    return edges.every((edge) => edge >= _minimumEdge) &&
        signedAreaTwice.abs() / 2 >= _minimumArea;
  }
}

enum _Edge { top, right, bottom, left }

class _RegionPainter extends CustomPainter {
  final List<Offset> points;
  const _RegionPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final border = Paint()
      ..color = const Color(0xFF2196F3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dash = 9.0;
    const gap = 6.0;
    for (var index = 0; index < points.length; index++) {
      final start = points[index];
      final end = points[(index + 1) % points.length];
      final vector = end - start;
      final length = vector.distance;
      final direction = vector / length;
      for (var distance = 0.0; distance < length; distance += dash + gap) {
        canvas.drawLine(start + direction * distance,
            start + direction * math.min(distance + dash, length), border);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RegionPainter oldDelegate) =>
      oldDelegate.points != points;
}
