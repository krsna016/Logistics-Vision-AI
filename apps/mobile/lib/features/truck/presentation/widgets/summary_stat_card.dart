import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// Animated counter card for prominent statistics display.
class SummaryStatCard extends StatefulWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final bool isAlert;

  const SummaryStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.isAlert = false,
  });

  @override
  State<SummaryStatCard> createState() => _SummaryStatCardState();
}

class _SummaryStatCardState extends State<SummaryStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _displayedValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _animation.addListener(() {
      setState(() {
        _displayedValue = (_animation.value * widget.value).toInt();
      });
    });
    _controller.forward();
  }

  @override
  void didUpdateWidget(SummaryStatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        widget.isAlert && widget.value > 0 ? AppTheme.errorColor : widget.color;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: effectiveColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 22, color: effectiveColor),
            const SizedBox(height: 8),
            Text(
              '$_displayedValue',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: effectiveColor,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.label.toUpperCase(),
              style: const TextStyle(
                fontSize: 9,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
