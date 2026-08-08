import 'package:flutter/material.dart';

class ScannerCaptureControls extends StatefulWidget {
  final bool torchOn;
  final bool isScanning;
  final VoidCallback? onToggleTorch;
  final VoidCallback? onCapture;
  final VoidCallback onGallery;
  final VoidCallback onFlipCamera;
  final String captureLabel;
  final bool twoButtonMode;
  final bool flashOnlyMode;

  const ScannerCaptureControls({
    super.key,
    required this.torchOn,
    required this.isScanning,
    required this.onToggleTorch,
    required this.onCapture,
    required this.onGallery,
    required this.onFlipCamera,
    required this.captureLabel,
    this.twoButtonMode = false,
    this.flashOnlyMode = false,
  });

  @override
  State<ScannerCaptureControls> createState() => _ScannerCaptureControlsState();
}

class _ScannerCaptureControlsState extends State<ScannerCaptureControls>
    with SingleTickerProviderStateMixin {
  late final AnimationController _menuController;
  bool _menuOpen = false;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      reverseDuration: const Duration(milliseconds: 180),
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() => _menuOpen = !_menuOpen);
    _menuOpen ? _menuController.forward() : _menuController.reverse();
  }

  void _runAndClose(VoidCallback action) {
    action();
    if (_menuOpen) _toggleMenu();
  }

  Widget _menuOption({
    required int index,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final animation = CurvedAnimation(
      parent: _menuController,
      curve: Interval(
        index * 0.12,
        0.84 + index * 0.12,
        curve: Curves.easeOutBack,
      ),
      reverseCurve: Curves.easeInCubic,
    );
    return Positioned(
      bottom: 62.0 + index * 60,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => IgnorePointer(
          ignoring: animation.value < 0.95,
          child: Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 16 * (1 - animation.value)),
              child: Transform.scale(
                scale: 0.72 + 0.28 * animation.value,
                child: child,
              ),
            ),
          ),
        ),
        child: _ScannerRoundButton(
          icon: icon,
          tooltip: tooltip,
          onTap: () => _runAndClose(onTap),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashOnlyMode) {
      return Align(
        alignment: Alignment.centerRight,
        child: _ScannerRoundButton(
          icon:
              widget.torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
          tooltip: widget.torchOn ? 'Turn flash off' : 'Turn flash on',
          onTap: widget.onToggleTorch,
        ),
      );
    }

    if (widget.twoButtonMode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ScannerRoundButton(
            icon: widget.torchOn
                ? Icons.flash_on_rounded
                : Icons.flash_off_rounded,
            tooltip: widget.torchOn ? 'Turn flash off' : 'Turn flash on',
            onTap: widget.onToggleTorch,
          ),
          const SizedBox(width: 28),
          _ScannerRoundButton(
            icon: Icons.photo_library_outlined,
            tooltip: 'Choose plate from gallery',
            onTap: widget.isScanning ? null : widget.onGallery,
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _ScannerRoundButton(
          icon:
              widget.torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
          tooltip: widget.torchOn ? 'Turn flash off' : 'Turn flash on',
          onTap: widget.onToggleTorch,
        ),
        Semantics(
          button: true,
          enabled: !widget.isScanning,
          label: widget.isScanning ? 'Reading number' : widget.captureLabel,
          child: GestureDetector(
            onTap: widget.isScanning ? null : widget.onCapture,
            child: AnimatedScale(
              scale: widget.isScanning ? 0.92 : 1,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: Container(
                width: 82,
                height: 82,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.45),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isScanning ? Colors.white70 : Colors.white,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: widget.isScanning
                        ? const SizedBox(
                            key: ValueKey('reading'),
                            width: 24,
                            height: 24,
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(
                            key: ValueKey('ready'),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 52,
          height: 172,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              _menuOption(
                index: 1,
                icon: Icons.photo_library_outlined,
                tooltip: 'Gallery',
                onTap: widget.onGallery,
              ),
              _menuOption(
                index: 0,
                icon: Icons.flip_camera_ios_outlined,
                tooltip: 'Flip camera',
                onTap: widget.onFlipCamera,
              ),
              _ScannerRoundButton(
                icon: _menuOpen ? Icons.close_rounded : Icons.more_vert_rounded,
                tooltip:
                    _menuOpen ? 'Close camera options' : 'More camera options',
                onTap: _toggleMenu,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScannerRoundButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _ScannerRoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: onTap == null ? 0.42 : 1,
      duration: const Duration(milliseconds: 160),
      child: Semantics(
        button: true,
        label: tooltip,
        child: Material(
          color: Colors.black.withValues(alpha: 0.58),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 52,
              height: 52,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 170),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  icon,
                  key: ValueKey(icon.codePoint),
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
