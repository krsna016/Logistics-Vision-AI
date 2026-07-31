import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// Animated loading progress bar with percentage and layer count labels.
class LoadingProgressCard extends StatefulWidget {
  final int completedLayers;
  final int totalLayers;

  const LoadingProgressCard({
    super.key,
    required this.completedLayers,
    required this.totalLayers,
  });

  @override
  State<LoadingProgressCard> createState() => _LoadingProgressCardState();
}

class _LoadingProgressCardState extends State<LoadingProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _updateAnimation(0.0);
    _controller.forward();
  }

  void _updateAnimation(double from) {
    final target = widget.totalLayers > 0
        ? widget.completedLayers / widget.totalLayers
        : 0.0;
    _progressAnimation = Tween<double>(begin: from, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(LoadingProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.completedLayers != widget.completedLayers ||
        oldWidget.totalLayers != widget.totalLayers) {
      final currentValue = _progressAnimation.value;
      _controller.reset();
      _updateAnimation(currentValue);
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
    final progress = widget.totalLayers > 0
        ? widget.completedLayers / widget.totalLayers
        : 0.0;
    final pct = (progress * 100).toInt();
    final Color progressColor = pct >= 100
        ? AppTheme.successColor
        : pct >= 60
            ? AppTheme.primaryColor
            : AppTheme.warningColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.stacked_bar_chart,
                      size: 16, color: AppTheme.textSecondary),
                  SizedBox(width: 8),
                  Text(
                    'LOADING PROGRESS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final animPct = (_progressAnimation.value * 100).toInt();
                  return Text(
                    '$animPct%',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: progressColor,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _progressAnimation.value,
                  minHeight: 10,
                  backgroundColor: AppTheme.dividerColor,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            '${widget.completedLayers} of ${widget.totalLayers} Layers Completed',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
