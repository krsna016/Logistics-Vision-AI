import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../presentation/widgets/app_card.dart';
import '../../../../presentation/widgets/stats_card.dart';
import '../../../../presentation/widgets/status_chip.dart';
import '../../../../presentation/widgets/empty_state_widget.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/wagon.dart';
import '../providers/wagon_providers.dart';
import '../../../truck/domain/entities/truck.dart';
import '../../../truck/presentation/providers/truck_providers.dart';
import '../../../truck/presentation/widgets/truck_form_dialog.dart';

class WagonDetailsScreen extends ConsumerWidget {
  final String wagonId;

  const WagonDetailsScreen({super.key, required this.wagonId});

  Color _getStatusColor(WagonStatus status) {
    switch (status) {
      case WagonStatus.planning:
        return AppTheme.primaryColor;
      case WagonStatus.loading:
        return AppTheme.warningColor;
      case WagonStatus.completed:
        return AppTheme.successColor;
      case WagonStatus.archived:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wagonState = ref.watch(wagonListProvider);
    final truckState = ref.watch(truckListProvider);
    final notifier = ref.read(wagonListProvider.notifier);

    // Look up the wagon record
    final wagon = wagonState.wagons.firstWhere(
      (w) => w.id == wagonId,
      orElse: () => Wagon(
        id: wagonId,
        wagonNumber: 'Unknown',
        origin: 'Unknown',
        destination: 'Unknown',
        loadingDate: DateTime.now(),
        expectedTruckCount: 0,
        completedTruckCount: 0,
        status: WagonStatus.planning,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    // Filter trucks belonging to this wagon
    final wagonTrucks = truckState.trucks.where((t) => t.wagonId == wagonId && !t.isDeleted).toList();
    final cartons = wagonTrucks.fold(0, (sum, t) => sum + t.totalCartons);
    final defects = wagonTrucks.fold(0, (sum, t) => sum + t.totalDefects);
    final completedCount = wagonTrucks.where((t) => t.status == TruckStatus.completed).length;

    final double progress = wagon.expectedTruckCount > 0 ? completedCount / wagon.expectedTruckCount : 0.0;
    final int progressPct = (progress * 100).toInt();
    final statusColor = _getStatusColor(wagon.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(wagon.wagonNumber),
        actions: [
          IconButton(
            icon: const Icon(Icons.description_outlined),
            onPressed: () => context.push('/registers/${wagon.id}'),
            tooltip: 'View Digital Register',
          ),
          if (wagon.status != WagonStatus.archived)
            IconButton(
              icon: const Icon(Icons.archive),
              onPressed: () async {
                await notifier.updateWagonStatus(wagon.id, WagonStatus.archived);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Wagon session archived successfully.')),
                  );
                }
              },
              tooltip: 'Archive Wagon',
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Delete Wagon',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext ctx) {
                  String inputValue = '';
                  return StatefulBuilder(
                    builder: (context, setState) {
                      final bool canDelete = inputValue == wagon.wagonNumber;
                      return AlertDialog(
                        title: const Text('Delete Wagon'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('This action cannot be undone. This will permanently delete the wagon and all its associated data.'),
                            const SizedBox(height: 16),
                            Text('Type "${wagon.wagonNumber}" to confirm.', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextField(
                              autofocus: true,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter wagon number',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  inputValue = value;
                                });
                              },
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: canDelete ? () async {
                              Navigator.of(ctx).pop();
                              
                              final truckNotifier = ref.read(truckListProvider.notifier);
                              final trucks = ref.read(truckListProvider).trucks.where((t) => t.wagonId == wagon.id).toList();
                              for (final t in trucks) {
                                await truckNotifier.deleteTruck(t.id);
                              }
                              
                              await notifier.deleteWagon(wagon.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Wagon deleted successfully.')),
                                );
                                context.pop();
                              }
                            } : null,
                            child: Text('Delete', style: TextStyle(color: canDelete ? Colors.redAccent : Colors.grey)),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Wagon Header Detail Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          wagon.wagonNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 0.5),
                        ),
                        StatusChip(
                          type: wagon.status == WagonStatus.loading
                              ? CustomStatusType.active
                              : (wagon.status == WagonStatus.completed
                                  ? CustomStatusType.completed
                                  : CustomStatusType.closed),
                          label: wagon.status.displayName,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Origin: ${wagon.origin}',
                      style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Destination: ${wagon.destination}',
                      style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Loading Date: ${_formatDate(wagon.loadingDate)}',
                      style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
                    ),
                    if (wagon.remarks != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Remarks: ${wagon.remarks}',
                        style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Statistics Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  StatsCard(
                    icon: '🚚',
                    value: '${wagonTrucks.length}',
                    title: 'Trucks Loaded',
                  ),
                  const SizedBox(width: 12),
                  StatsCard(
                    icon: '📦',
                    value: '$cartons',
                    title: 'Total Cartons',
                  ),
                  const SizedBox(width: 12),
                  StatsCard(
                    icon: '⚠️',
                    value: '$defects',
                    title: 'Total Defects',
                  ),
                ],
              ),
            ),

            // Progress Bar section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expected Truck Loading Progress: $completedCount / ${wagon.expectedTruckCount} ($progressPct%)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFBDBDBD)),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFF3A3A3A),
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Generate Report'),
                            content: const Text('Exporting wagon loading logs to PDF report...'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Generate Report'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (wagon.status == WagonStatus.loading)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _confirmCompleteWagon(context, notifier, wagon, wagonTrucks, cartons, completedCount),
                        icon: const Icon(Icons.done_all),
                        label: const Text('Complete Wagon'),
                      ),
                    )
                  else if (wagon.status == WagonStatus.planning)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await notifier.updateWagonStatus(wagon.id, WagonStatus.loading);
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Loading'),
                      ),
                    ),
                ],
              ),
            ),

            // List Title
            const Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 8.0),
              child: Text(
                'Registered Trucks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // Associated Trucks List or Empty State
            if (wagonTrucks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: AppCard(
                  child: Column(
                    children: [
                      const EmptyStateWidget(
                        title: 'No Trucks Added',
                        subtitle: 'Register your first truck for this wagon.',
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _openAddTruckDialog(context, wagon.id),
                        icon: const Icon(Icons.add),
                        label: const Text('Register Truck'),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: wagonTrucks.map((truck) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildTruckRowCard(context, truck),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: wagonTrucks.isNotEmpty && wagon.status != WagonStatus.archived
          ? FloatingActionButton(
              onPressed: () => _openAddTruckDialog(context, wagon.id),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _openAddTruckDialog(BuildContext context, String wagonId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TruckFormDialog(wagonId: wagonId),
    );
  }

  void _confirmCompleteWagon(
    BuildContext context, 
    WagonListNotifier notifier, 
    Wagon wagon, 
    List<Truck> trucks, 
    int totalCartons, 
    int completedCount,
  ) {
    final missingCount = wagon.expectedTruckCount - completedCount;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Wagon Session?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will finalize the wagon and make it ready for the digital register.', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            _buildMetricSub('Total Trucks Loaded', '$completedCount / ${wagon.expectedTruckCount}'),
            const SizedBox(height: 8),
            _buildMetricSub('Total Cartons', '$totalCartons'),
            if (missingCount > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.warningColor.withOpacity(0.1), border: Border.all(color: AppTheme.warningColor), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_outlined, color: AppTheme.warningColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Warning: $missingCount trucks are missing from the expected count.', style: const TextStyle(color: AppTheme.warningColor, fontSize: 12))),
                  ],
                ),
              )
            ]
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await notifier.updateWagonStatus(wagon.id, WagonStatus.completed);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Wagon status marked Completed.')));
                ctx.push('/registers/${wagon.id}');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
            child: const Text('Complete & Generate'),
          ),
        ],
      ),
    );
  }

  Widget _buildTruckRowCard(BuildContext context, Truck truck) {
    final statusColor = truck.status == TruckStatus.completed
        ? AppTheme.successColor
        : AppTheme.warningColor;

    return AppCard(
      elevation: 1,
      onTap: () => context.push('/trucks/${truck.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                truck.vehicleNumber,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              StatusChip(
                type: truck.status == TruckStatus.completed
                    ? CustomStatusType.completed
                    : CustomStatusType.active,
                label: truck.status.displayName,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Driver: ${truck.driverName}${truck.driverMobile != null && truck.driverMobile!.isNotEmpty ? ' (${truck.driverMobile})' : ''}  •  Carrier: ${truck.company}',
            style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 12),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(height: 1, color: Color(0xFF3A3A3A)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricSub('Layers', '${truck.totalLayers}'),
              _buildMetricSub('Cartons', '${truck.totalCartons}'),
              _buildMetricSub('Defects', '${truck.totalDefects}', isAlert: truck.totalDefects > 0),
              const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD), size: 18),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetricSub(String label, String value, {bool isAlert = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 9, color: Color(0xFFBDBDBD), fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isAlert ? AppTheme.errorColor : Colors.white,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
