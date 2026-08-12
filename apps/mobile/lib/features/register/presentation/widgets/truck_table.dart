import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../layer/domain/entities/layer.dart';
import '../../../truck/domain/entities/truck.dart';

class TruckTable extends StatelessWidget {
  final List<Truck> trucks;
  final Map<String, List<LayerRecord>> layersByTruck;
  final ValueChanged<Truck>? onTruckTap;

  const TruckTable({
    super.key,
    required this.trucks,
    required this.layersByTruck,
    this.onTruckTap,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Truck and Layer Register',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ...trucks.indexed.map((entry) {
              final truck = entry.$2;
              final layers = layersByTruck[truck.id] ?? const <LayerRecord>[];
              return ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor:
                      AppTheme.primaryColor.withValues(alpha: 0.15),
                  child: Text('${entry.$1 + 1}',
                      style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold)),
                ),
                title: Text(truck.vehicleNumber,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(
                  'Driver: ${truck.driverName}\n'
                  '${truck.totalLayers} layers | ${truck.totalCartons} cartons | '
                  '${truck.totalDefects} defects',
                ),
                trailing: _status(truck.status.displayName),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Row(
                      children: [
                        Expanded(child: Text('Carrier: ${truck.company}')),
                        TextButton.icon(
                          onPressed: onTruckTap == null
                              ? null
                              : () => onTruckTap!(truck),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('Truck details'),
                        ),
                      ],
                    ),
                  ),
                  if (layers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No active layers recorded.'),
                    )
                  else
                    ...layers.map(_layerTile),
                ],
              );
            }),
          ],
        ),
      );

  Widget _layerTile(LayerRecord layer) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Layer ${layer.layerNumber}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Text('${layer.cartonCount} cartons',
                    style: const TextStyle(
                        color: AppTheme.warningColor,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Text('${layer.defectCount} defects',
                    style: TextStyle(
                        color: layer.defectCount > 0
                            ? AppTheme.errorColor
                            : AppTheme.textSecondary)),
              ],
            ),
            if (layer.itemAllocations.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: layer.itemAllocations
                    .map((item) => Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text('${item.itemName}: ${item.quantity}'),
                        ))
                    .toList(),
              ),
            ],
            if (layer.notes?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 6),
              Text(layer.notes!,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
            ],
            const SizedBox(height: 5),
            Text('${layer.operatorId} | ${_time(layer.timestamp)}',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 10)),
          ],
        ),
      );

  Widget _status(String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(value,
            style: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 9,
                fontWeight: FontWeight.bold)),
      );

  static String _time(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')} '
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}
