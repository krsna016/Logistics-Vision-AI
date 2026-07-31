import 'package:flutter/material.dart';
import '../../../../core/presentation/layout/responsive.dart';
import '../../../../theme/app_theme.dart';

class MetricTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? subtitle;

  const MetricTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = AppTheme.primaryColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppResponsive.cardPadding(context)),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: AppResponsive.text(context, 24),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class SummaryGrid extends StatelessWidget {
  final int totalWagons;
  final int totalTrucks;
  final int totalLayers;
  final int totalCartons;
  final double avgConfidence;
  final Duration avgLoadingTime;

  const SummaryGrid({
    super.key,
    required this.totalWagons,
    required this.totalTrucks,
    required this.totalLayers,
    required this.totalCartons,
    required this.avgConfidence,
    required this.avgLoadingTime,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: AppResponsive.isCompact(context) ? 170 : 190,
        crossAxisSpacing: AppResponsive.gap(context),
        mainAxisSpacing: AppResponsive.gap(context),
        childAspectRatio: AppResponsive.isCompact(context) ? 1.25 : 1.5,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) => [
        MetricTile(
          title: 'Wagons',
          value: totalWagons.toString(),
          icon: Icons.train,
        ),
        MetricTile(
          title: 'Trucks',
          value: totalTrucks.toString(),
          icon: Icons.local_shipping,
          iconColor: Colors.orange,
        ),
        MetricTile(
          title: 'Layers',
          value: totalLayers.toString(),
          icon: Icons.layers,
          iconColor: Colors.purple,
        ),
        MetricTile(
          title: 'Cartons',
          value: totalCartons.toString(),
          icon: Icons.inventory_2,
          iconColor: Colors.green,
        ),
        MetricTile(
          title: 'AI Confidence',
          value: '${(avgConfidence * 100).toStringAsFixed(1)}%',
          icon: Icons.psychology,
          iconColor: avgConfidence >= 0.90 ? Colors.green : Colors.redAccent,
        ),
        MetricTile(
          title: 'Avg Load Time',
          value: '${avgLoadingTime.inMinutes}m',
          icon: Icons.timer,
          iconColor: Colors.blueAccent,
        ),
      ][index],
    );
  }
}
