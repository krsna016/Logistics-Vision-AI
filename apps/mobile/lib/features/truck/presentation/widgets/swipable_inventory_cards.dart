import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../layer/domain/entities/layer.dart';
import '../../../wagon/domain/entities/wagon.dart';
import '../../../wagon/presentation/widgets/wagon_inventory_card.dart';

class SwipableInventoryCards extends StatefulWidget {
  final Wagon wagon;
  final Map<String, int> globalLoadedByItem;
  final bool isLoading;
  final List<LayerRecord> truckLayers;

  const SwipableInventoryCards({
    super.key,
    required this.wagon,
    required this.globalLoadedByItem,
    required this.isLoading,
    required this.truckLayers,
  });

  @override
  State<SwipableInventoryCards> createState() => _SwipableInventoryCardsState();
}

class _SwipableInventoryCardsState extends State<SwipableInventoryCards> {
  bool _showTruckBreakdown = false;

  @override
  Widget build(BuildContext context) {
    final truckLoadedByItem = <String, int>{};
    for (final layer in widget.truckLayers) {
      for (final alloc in layer.itemAllocations) {
        truckLoadedByItem[alloc.itemName] =
            (truckLoadedByItem[alloc.itemName] ?? 0) + alloc.quantity;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onPanEnd: (details) {
            if (details.velocity.pixelsPerSecond.dx > 100) {
              setState(() => _showTruckBreakdown = false); // swipe right
            } else if (details.velocity.pixelsPerSecond.dx < -100) {
              setState(() => _showTruckBreakdown = true); // swipe left
            }
          },
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _showTruckBreakdown
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: WagonInventoryCard(
              wagon: widget.wagon,
              loadedByItem: widget.globalLoadedByItem,
              isLoading: widget.isLoading,
              matchTruckHeader: true,
            ),
            secondChild: _buildTruckBreakdownCard(truckLoadedByItem),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDot(!_showTruckBreakdown),
            const SizedBox(width: 6),
            _buildDot(_showTruckBreakdown),
          ],
        ),
      ],
    );
  }

  Widget _buildTruckBreakdownCard(Map<String, int> truckLoaded) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1B2A), Color(0xFF1E2D3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                child: const Icon(Icons.local_shipping_outlined,
                    color: AppTheme.primaryColor, size: 21),
              ),
              const SizedBox(width: 10),
              const Text(
                'Truck Item Breakdown',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (truckLoaded.isEmpty)
            const Text(
              'No items loaded in this truck yet.',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            )
          else
            ...truckLoaded.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.035),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${entry.value} loaded',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 6,
      width: active ? 16 : 6,
      decoration: BoxDecoration(
        color: active ? AppTheme.primaryColor : Colors.grey.withAlpha(100),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
