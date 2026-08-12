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

import '../../../../core/presentation/widgets/action_warning_dialog.dart';
import '../../../../core/presentation/widgets/strict_action_warning_dialog.dart';
import '../../../truck/presentation/providers/truck_providers.dart';
import '../../../truck/presentation/widgets/truck_form_dialog.dart';
import '../../../reports/presentation/providers/report_providers.dart';
import '../../../reports/presentation/widgets/generate_report_dialog.dart';
import '../widgets/create_wagon_sheet.dart';
import '../widgets/wagon_inventory_card.dart';

class WagonDetailsScreen extends ConsumerWidget {
  final String wagonId;

  const WagonDetailsScreen({super.key, required this.wagonId});

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
    final wagonTrucks = truckState.trucks
        .where((t) => t.wagonId == wagonId && !t.isDeleted)
        .toList();
    final cartons = wagonTrucks.fold(0, (sum, t) => sum + t.totalCartons);
    final defects = wagonTrucks.fold(0, (sum, t) => sum + t.totalDefects);
    final completedCount =
        wagonTrucks.where((t) => t.status == TruckStatus.completed).length;

    final inventory = ref.watch(wagonInventoryProvider(wagonId));
    final manifestReconciled = wagon.isManifestReconciled(
      inventory.valueOrNull ?? const <String, int>{},
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/wagons');
            }
          },
        ),
        title: const Text('Wagon Details'),
        actions: [
          if (wagon.status != WagonStatus.archived)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Wagon Details',
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: false,
                  enableDrag: false,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => CreateWagonSheet(existingWagon: wagon),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.assessment_outlined),
            tooltip: 'Generate Report',
            onPressed: () => _showUnifiedReportDialog(context, ref, wagonId),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Delete Wagon',
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => StrictActionWarningDialog(
                  title: 'Remove Wagon?',
                  content:
                      'This removes the wagon and all associated trucks and layers from active views and future reports. The action is recorded for audit.',
                  expectedConfirmationText: wagon.wagonNumber,
                  actionLabel: 'Delete',
                  actionColor: Colors.redAccent,
                  onConfirm: () async {
                    await notifier.deleteWagon(wagon.id);
                    await ref.read(truckListProvider.notifier).refresh();
                    if (context.mounted) {
                      context.go('/wagons');
                    }
                  },
                ),
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
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              letterSpacing: 0.5),
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
                      style: const TextStyle(
                          color: Color(0xFFBDBDBD), fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Destination: ${wagon.destination}',
                      style: const TextStyle(
                          color: Color(0xFFBDBDBD), fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Loading Date: ${_formatDate(wagon.loadingDate)}',
                      style: const TextStyle(
                          color: Color(0xFFBDBDBD), fontSize: 14),
                    ),
                    if (wagon.remarks != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Remarks: ${wagon.remarks}',
                        style: const TextStyle(
                            color: Color(0xFFBDBDBD),
                            fontSize: 12,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (wagon.items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: WagonInventoryCard(
                  wagon: wagon,
                  loadedByItem: inventory.valueOrNull ?? const {},
                  isLoading: inventory.isLoading,
                ),
              ),

            // Statistics Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  StatsCard(
                    icon: Icons.local_shipping_outlined,
                    value: '${wagonTrucks.length}',
                    title: 'Trucks Loaded',
                  ),
                  const SizedBox(width: 12),
                  StatsCard(
                    icon: Icons.inventory_2_outlined,
                    value: '$cartons',
                    title: 'Total Cartons',
                  ),
                  const SizedBox(width: 12),
                  StatsCard(
                    icon: Icons.warning_amber_outlined,
                    value: '$defects',
                    title: 'Total Defects',
                  ),
                ],
              ),
            ),

            // List Title
            const Padding(
              padding: EdgeInsets.only(
                  left: 16.0, right: 16.0, top: 24.0, bottom: 8.0),
              child: Text(
                'Registered Trucks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // Associated Trucks List or Empty State
            if (wagonTrucks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: AppCard(
                  child: Column(
                    children: [
                      EmptyStateWidget(
                        title: 'No Trucks Added',
                        subtitle: 'Register your first truck for this wagon.',
                      ),
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
      bottomNavigationBar: _WagonBottomBar(
        isArchived: wagon.status == WagonStatus.archived,
        canComplete: wagon.status == WagonStatus.loading &&
            wagonTrucks.isNotEmpty &&
            completedCount == wagonTrucks.length &&
            manifestReconciled,
        onRegisterTruck: () => _openAddTruckDialog(context, ref, wagon.id),
        onComplete: () => _confirmCompleteWagon(
          context,
          notifier,
          wagon,
          wagonTrucks,
          cartons,
          completedCount,
        ),
        onArchive: wagon.status == WagonStatus.completed && manifestReconciled
            ? () => _confirmArchive(context, notifier, wagon)
            : null,
      ),
    );
  }

  void _showUnifiedReportDialog(
      BuildContext context, WidgetRef ref, String wagonId) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (_) => GenerateReportDialog(
        title: 'Generate Wagon Report',
        subtitle:
            'Export truck loading records, carton totals, layer history, and defect records for this wagon.',
        onPdf: () => _exportWagonReport(context, ref, wagonId, 'PDF'),
        onExcel: () => _exportWagonReport(context, ref, wagonId, 'Excel'),
      ),
    );
  }

  Future<void> _exportWagonReport(
      BuildContext context, WidgetRef ref, String wagonId, String type) async {
    try {
      final file = type == 'PDF'
          ? await ref
              .read(pdfReportServiceProvider)
              .generateWagonReport(wagonId: wagonId)
          : await ref
              .read(excelReportServiceProvider)
              .generateWagonReport(wagonId: wagonId);
      await ref
          .read(shareServiceProvider)
          .shareFile(file, subject: 'Wagon Loading Report ($type)');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  // ignore: unused_element
  void _showWagonReportDialog(
      BuildContext context, WidgetRef ref, String wagonId) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.12),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF102A43), Color(0xFF173D5C)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.assessment_outlined,
                        color: AppTheme.primaryColor,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Generate Report',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Export this wagon loading record',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close,
                          color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Choose a format. The report includes wagon details, truck loading totals, cartons, and defects.',
                      style:
                          TextStyle(color: AppTheme.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 18),
                    _WagonReportFormatButton(
                      icon: Icons.table_chart_outlined,
                      title: 'Excel Spreadsheet',
                      subtitle: 'Best for editing and analysis',
                      color: AppTheme.successColor,
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          final file = await ref
                              .read(excelReportServiceProvider)
                              .generateWagonReport(wagonId: wagonId);
                          await ref.read(shareServiceProvider).shareFile(
                                file,
                                subject: 'Wagon Loading Report (Excel)',
                              );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: $e')),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _WagonReportFormatButton(
                      icon: Icons.picture_as_pdf_outlined,
                      title: 'PDF Document',
                      subtitle: 'Best for printing and sharing',
                      color: AppTheme.primaryColor,
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          final file = await ref
                              .read(pdfReportServiceProvider)
                              .generateWagonReport(wagonId: wagonId);
                          await ref.read(shareServiceProvider).shareFile(
                                file,
                                subject: 'Wagon Loading Report (PDF)',
                              );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openAddTruckDialog(
      BuildContext context, WidgetRef ref, String wagonId) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TruckFormDialog(wagonId: wagonId),
    );

    await ref.read(truckListProvider.notifier).refresh();
    final wagon = ref.read(wagonListProvider).wagons.firstWhere(
          (item) => item.id == wagonId,
          orElse: () => throw StateError('Wagon not found'),
        );
    final hasTrucks = ref
        .read(truckListProvider)
        .trucks
        .any((truck) => truck.wagonId == wagonId && !truck.isDeleted);
    if (wagon.status == WagonStatus.planning && hasTrucks) {
      await ref
          .read(wagonListProvider.notifier)
          .updateWagonStatus(wagonId, WagonStatus.loading);
    }
  }

  void _confirmArchive(
    BuildContext context,
    WagonListNotifier notifier,
    Wagon wagon,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => ActionWarningDialog(
        title: 'Archive Wagon?',
        content:
            'This wagon will leave the active loading view and remain in Digital Registers. Operational loading is locked, while controlled corrections remain available there.',
        actionLabel: 'Archive',
        actionColor: AppTheme.textSecondary,
        icon: Icons.archive_outlined,
        onConfirm: () {
          notifier
              .updateWagonStatus(wagon.id, WagonStatus.archived)
              .then((error) {
            if (!context.mounted) return;
            if (error != null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(error)));
              return;
            }
            context.go('/wagons');
          });
        },
      ),
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
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Wagon Session?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'This will finalize the wagon and make it ready for the digital register.',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            _buildMetricSub('Completed Trucks', '$completedCount'),
            const SizedBox(height: 8),
            _buildMetricSub('Total Cartons', '$totalCartons'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final error = await notifier.updateWagonStatus(
                  wagon.id, WagonStatus.completed);
              if (error != null && ctx.mounted) {
                ScaffoldMessenger.of(ctx)
                    .showSnackBar(SnackBar(content: Text(error)));
                return;
              }
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  Widget _buildTruckRowCard(BuildContext context, Truck truck) {
    return AppCard(
      elevation: 1,
      onTap: () => context.push('/trucks/${truck.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  truck.vehicleNumber,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(
                type: truck.status == TruckStatus.completed
                    ? CustomStatusType.completed
                    : CustomStatusType.active,
                label: truck.status.displayName,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.fingerprint_outlined,
                  size: 13, color: Color(0xFF7E8A99)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'ID: ${truck.id}',
                  style: const TextStyle(
                      color: Color(0xFF7E8A99),
                      fontSize: 10,
                      fontFamily: 'monospace'),
                  overflow: TextOverflow.ellipsis,
                ),
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
              _buildMetricSub('Defects', '${truck.totalDefects}',
                  isAlert: truck.totalDefects > 0),
              const Icon(Icons.chevron_right,
                  color: Color(0xFFBDBDBD), size: 18),
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
          style: const TextStyle(
              fontSize: 9,
              color: Color(0xFFBDBDBD),
              fontWeight: FontWeight.bold),
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _WagonBottomBar extends StatelessWidget {
  static const double _actionHeight = 56;
  final bool isArchived;
  final bool canComplete;
  final VoidCallback onRegisterTruck;
  final VoidCallback onComplete;
  final VoidCallback? onArchive;

  const _WagonBottomBar({
    required this.isArchived,
    required this.canComplete,
    required this.onRegisterTruck,
    required this.onComplete,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: const Border(top: BorderSide(color: AppTheme.dividerColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: onArchive != null
          ? SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onArchive,
                icon: const Icon(Icons.archive_outlined),
                label: const Text('Archive Wagon',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textSecondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(_actionHeight),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isArchived ? null : onRegisterTruck,
                    icon: const Icon(Icons.local_shipping_outlined, size: 20),
                    label: const Text(
                      'Register New Truck',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isArchived
                          ? AppTheme.dividerColor
                          : AppTheme.primaryColor,
                      foregroundColor:
                          isArchived ? AppTheme.textSecondary : Colors.white,
                      minimumSize: const Size.fromHeight(_actionHeight),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: _actionHeight,
                  height: _actionHeight,
                  child: IconButton(
                    onPressed: canComplete ? onComplete : null,
                    tooltip: 'Complete Wagon',
                    icon: const Icon(Icons.check_rounded, size: 27),
                    style: IconButton.styleFrom(
                      backgroundColor: canComplete
                          ? AppTheme.successColor
                          : AppTheme.dividerColor,
                      foregroundColor:
                          canComplete ? Colors.white : AppTheme.textSecondary,
                      side: BorderSide(
                        color: canComplete
                            ? AppTheme.successColor
                            : AppTheme.textSecondary.withValues(alpha: 0.55),
                        width: 1.2,
                      ),
                      shape: const CircleBorder(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _WagonReportFormatButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onPressed;

  const _WagonReportFormatButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 15),
          ],
        ),
      ),
    );
  }
}
