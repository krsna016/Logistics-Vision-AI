import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class ProgressSection extends StatelessWidget {
  final int expectedTrucks;
  final int completedTrucks;
  final int expectedLayers;
  final int completedLayers;
  final int cartonsCounted;
  final int? estimatedRemainingCartons;

  const ProgressSection({
    super.key,
    required this.expectedTrucks,
    required this.completedTrucks,
    required this.expectedLayers,
    required this.completedLayers,
    required this.cartonsCounted,
    this.estimatedRemainingCartons,
  });

  @override
  Widget build(BuildContext context) {
    final double truckPct = expectedTrucks > 0 ? (completedTrucks / expectedTrucks).clamp(0.0, 1.0) : 0.0;
    final double layerPct = expectedLayers > 0 ? (completedLayers / expectedLayers).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.donut_large_outlined, color: AppTheme.primaryColor, size: 18),
              SizedBox(width: 8),
              Text(
                'Operational Progress & Estimations',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Truck Progress Bar
          _ProgressRow(
            title: 'Trucks Progress',
            subtitle: '$completedTrucks of $expectedTrucks Trucks Completed',
            percentage: (truckPct * 100).toInt(),
            progressValue: truckPct,
            progressColor: AppTheme.primaryColor,
          ),
          const SizedBox(height: 14),

          // Layer Progress Bar
          _ProgressRow(
            title: 'Layers Progress',
            subtitle: '$completedLayers of $expectedLayers Layers Completed',
            percentage: (layerPct * 100).toInt(),
            progressValue: layerPct,
            progressColor: AppTheme.warningColor,
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.dividerColor, height: 1),
          const SizedBox(height: 14),

          // Bottom Metric Counter Badges
          Row(
            children: [
              Expanded(
                child: _BadgeBox(
                  label: 'Cartons Counted',
                  value: '$cartonsCounted',
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BadgeBox(
                  label: 'Est. Remaining',
                  value: estimatedRemainingCartons != null ? '$estimatedRemainingCartons' : 'Calculating...',
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final int percentage;
  final double progressValue;
  final Color progressColor;

  const _ProgressRow({
    required this.title,
    required this.subtitle,
    required this.percentage,
    required this.progressValue,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
            Text('$percentage%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: progressColor)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progressValue,
            minHeight: 8,
            backgroundColor: AppTheme.cardColor,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }
}

class _BadgeBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BadgeBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
