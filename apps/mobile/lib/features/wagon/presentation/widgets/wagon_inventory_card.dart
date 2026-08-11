import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../presentation/widgets/app_card.dart';
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
    final loaded = wagon.items
        .fold<int>(0, (sum, item) => sum + (loadedByItem[item.name] ?? 0));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined,
                  color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Wagon Item Inventory',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
              if (isLoading)
                const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: 4),
          Text('$loaded of $total cartons loaded • ${total - loaded} remaining',
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(flex: 4, child: _Heading('Item')),
              Expanded(child: _Heading('Total')),
              Expanded(child: _Heading('Loaded')),
              Expanded(child: _Heading('Left')),
            ],
          ),
          const Divider(color: AppTheme.dividerColor),
          ...wagon.items.map((item) {
            final itemLoaded = loadedByItem[item.name] ?? 0;
            final remaining = item.quantity - itemLoaded;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(item.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Expanded(child: Text('${item.quantity}')),
                  Expanded(
                    child: Text('$itemLoaded',
                        style: const TextStyle(color: AppTheme.primaryColor)),
                  ),
                  Expanded(
                    child: Text('$remaining',
                        style: TextStyle(
                            color: remaining < 0
                                ? AppTheme.errorColor
                                : AppTheme.successColor,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  const _Heading(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.bold));
}
