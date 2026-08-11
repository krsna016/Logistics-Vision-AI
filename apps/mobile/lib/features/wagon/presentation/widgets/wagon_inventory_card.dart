import 'package:flutter/material.dart';

import '../../../../presentation/widgets/app_card.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/wagon.dart';

class WagonInventoryCard extends StatelessWidget {
  final Wagon wagon;
  final Map<String, int> loadedByItem;
  final bool isLoading;

  const WagonInventoryCard({
    super.key,
    required this.wagon,
    required this.loadedByItem,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (wagon.items.isEmpty) return const SizedBox.shrink();
    final total = wagon.items.fold<int>(0, (sum, item) => sum + item.quantity);
    final loaded = wagon.items.fold<int>(
      0,
      (sum, item) => sum + (loadedByItem[item.name] ?? 0),
    );
    final remaining = total - loaded;
    final progress = total == 0 ? 0.0 : (loaded / total).clamp(0.0, 1.0);
    final percentage = (progress * 100).round();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: AppTheme.primaryColor, size: 21),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Wagon Item Inventory',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    SizedBox(height: 2),
                    Text('Live loading balance',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 10)),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                _PercentageBadge(value: percentage),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryValue(
                  value: '$loaded',
                  label: 'LOADED',
                  color: AppTheme.primaryColor,
                ),
              ),
              Container(width: 1, height: 36, color: AppTheme.dividerColor),
              Expanded(
                child: _SummaryValue(
                  value: '$remaining',
                  label: 'REMAINING',
                  color: remaining < 0
                      ? AppTheme.errorColor
                      : AppTheme.warningColor,
                ),
              ),
              Container(width: 1, height: 36, color: AppTheme.dividerColor),
              Expanded(
                child: _SummaryValue(
                  value: '$total',
                  label: 'TOTAL',
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          _ProgressBar(value: progress, color: AppTheme.primaryColor),
          const SizedBox(height: 18),
          ...wagon.items.indexed.map((entry) {
            final index = entry.$1;
            final item = entry.$2;
            final itemLoaded = loadedByItem[item.name] ?? 0;
            final itemRemaining = item.quantity - itemLoaded;
            return Padding(
              padding: EdgeInsets.only(
                  bottom: index == wagon.items.length - 1 ? 0 : 10),
              child: _InventoryItemRow(
                item: item,
                loaded: itemLoaded,
                remaining: itemRemaining,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PercentageBadge extends StatelessWidget {
  final int value;
  const _PercentageBadge({required this.value});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.25)),
        ),
        child: Text('$value% loaded',
            style: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.w800)),
      );
}

class _SummaryValue extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _SummaryValue({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 1),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7)),
        ],
      );
}

class _InventoryItemRow extends StatelessWidget {
  final WagonItem item;
  final int loaded;
  final int remaining;

  const _InventoryItemRow({
    required this.item,
    required this.loaded,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        item.quantity == 0 ? 0.0 : (loaded / item.quantity).clamp(0.0, 1.0);
    final isComplete = remaining == 0;
    final isOverloaded = remaining < 0;
    final statusColor = isOverloaded
        ? AppTheme.errorColor
        : isComplete
            ? AppTheme.successColor
            : AppTheme.warningColor;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isOverloaded
                      ? '${-remaining} OVER'
                      : isComplete
                          ? 'COMPLETE'
                          : '$remaining LEFT',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text('$loaded loaded of ${item.quantity} cartons',
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
          const SizedBox(height: 9),
          _ProgressBar(
            value: progress,
            color: isComplete ? AppTheme.successColor : AppTheme.primaryColor,
            height: 6,
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const _ProgressBar({
    required this.value,
    required this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: LinearProgressIndicator(
          value: value,
          minHeight: height,
          backgroundColor: Colors.white.withValues(alpha: 0.08),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
}
