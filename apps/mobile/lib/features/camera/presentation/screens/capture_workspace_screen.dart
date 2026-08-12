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

  void _showMode(CountMode mode) {
    if (_mode == mode) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _mode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final aiActive = _mode == CountMode.ai;

    // Keep both workspaces mounted and the preview warm so AI/manual mode
    // changes remain instant and preserve the operator's form state. Modes are
    // deliberately changed only through their visible controls, never swipes.
    return IndexedStack(
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
    );
  }
}
