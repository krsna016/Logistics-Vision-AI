import 'package:flutter/material.dart';

import 'camera_screen.dart';
import 'count_method_screens.dart';

class CaptureWorkspaceScreen extends StatefulWidget {
  final String truckId;
  final CountMode initialMode;

  const CaptureWorkspaceScreen({
    super.key,
    required this.truckId,
    this.initialMode = CountMode.ai,
  });

  @override
  State<CaptureWorkspaceScreen> createState() => _CaptureWorkspaceScreenState();
}

class _CaptureWorkspaceScreenState extends State<CaptureWorkspaceScreen> {
  late CountMode _mode = widget.initialMode;
  final Set<int> _activePointers = <int>{};
  Offset? _swipeStart;
  Offset? _swipeLast;

  void _showMode(CountMode mode) {
    if (_mode == mode) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _mode = mode);
  }

  void _handlePointerDown(PointerDownEvent event) {
    _activePointers.add(event.pointer);
    if (_activePointers.length == 1) {
      _swipeStart = event.position;
      _swipeLast = event.position;
    } else {
      // Two-finger gestures belong exclusively to camera pinch zoom.
      _swipeStart = null;
      _swipeLast = null;
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_activePointers.length == 1 &&
        _activePointers.contains(event.pointer)) {
      _swipeLast = event.position;
    }
  }

  void _handlePointerEnd(PointerEvent event) {
    final wasOnlyPointer =
        _activePointers.length == 1 && _activePointers.contains(event.pointer);
    final start = _swipeStart;
    final end = _swipeLast;
    _activePointers.remove(event.pointer);
    _swipeStart = null;
    _swipeLast = null;
    if (!wasOnlyPointer || start == null || end == null) return;

    final delta = end - start;
    final isHorizontalSwipe =
        delta.dx.abs() >= 72 && delta.dx.abs() > delta.dy.abs() * 1.35;
    if (!isHorizontalSwipe) return;
    if (delta.dx < 0 && _mode == CountMode.ai) {
      _showMode(CountMode.manual);
    } else if (delta.dx > 0 && _mode == CountMode.manual) {
      _showMode(CountMode.ai);
    }
  }

  void _handlePointerCancel(PointerEvent event) {
    _activePointers.remove(event.pointer);
    _swipeStart = null;
    _swipeLast = null;
  }

  @override
  Widget build(BuildContext context) {
    final aiActive = _mode == CountMode.ai;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerEnd,
      onPointerCancel: _handlePointerCancel,
      child: IndexedStack(
        index: aiActive ? 0 : 1,
        sizing: StackFit.expand,
        children: [
          TickerMode(
            enabled: aiActive,
            child: CameraScreen(
              isActive: aiActive,
              onManualSelected: () => _showMode(CountMode.manual),
            ),
          ),
          TickerMode(
            enabled: !aiActive,
            child: ManualCountScreen(
              truckId: widget.truckId,
              onAiSelected: () => _showMode(CountMode.ai),
            ),
          ),
        ],
      ),
    );
  }
}
