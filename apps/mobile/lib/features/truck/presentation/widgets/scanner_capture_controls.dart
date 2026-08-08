import 'package:flutter/material.dart';

class ScannerCaptureControls extends StatelessWidget {
  final bool torchOn;
  final VoidCallback? onToggleTorch;

  const ScannerCaptureControls({
    super.key,
    required this.torchOn,
    required this.onToggleTorch,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: AnimatedOpacity(
        opacity: onToggleTorch == null ? 0.42 : 1,
        duration: const Duration(milliseconds: 160),
        child: Semantics(
          button: true,
          label: torchOn ? 'Turn flash off' : 'Turn flash on',
          child: Material(
            color: Colors.black.withValues(alpha: 0.58),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onToggleTorch,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 52,
                height: 52,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 170),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    key: ValueKey(torchOn),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
