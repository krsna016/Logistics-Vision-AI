import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../../../core/presentation/widgets/strict_action_warning_dialog.dart';
import '../../../../core/presentation/widgets/action_warning_dialog.dart';
import '../../domain/entities/truck.dart';
import '../providers/truck_providers.dart';
import '../../../layer/presentation/providers/layer_providers.dart';
import '../../../layer/domain/entities/layer.dart';
import '../../../session/presentation/providers/session_providers.dart';
import '../../../reports/presentation/providers/report_providers.dart';
import '../../../reports/presentation/widgets/generate_report_dialog.dart';

import '../widgets/truck_form_dialog.dart';
import '../widgets/truck_header.dart';
import '../widgets/summary_stat_card.dart';
import '../widgets/layer_timeline.dart';
import '../../../wagon/domain/entities/wagon.dart';
import '../../../wagon/presentation/providers/wagon_providers.dart';
import '../../../wagon/presentation/widgets/wagon_inventory_card.dart';

class TruckDetailsScreen extends ConsumerWidget {
  final String truckId;
  final Truck? fallbackTruck;
  final bool allowArchivedEditing;

  const TruckDetailsScreen({
    super.key,
    required this.truckId,
    this.fallbackTruck,
    this.allowArchivedEditing = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(truckListProvider);
    final notifier = ref.read(truckListProvider.notifier);
    final layerState = ref.watch(layerListProvider(truckId));
    final layerNotifier = ref.read(layerListProvider(truckId).notifier);
    final sessionState = ref.watch(activeSessionProvider);
    final sessionNotifier = ref.read(activeSessionProvider.notifier);
    final wagonState = ref.watch(wagonListProvider);

    final truck = listState.trucks.firstWhere(
      (e) => e.id == truckId,
      orElse: () =>
          fallbackTruck ??
          Truck(
            id: '',
            truckNumber: 'Not Found',
            vehicleNumber: '',
            driverName: '',
            company: '',
            warehouse: '',
            status: TruckStatus.loading,
            createdDate: DateTime.now(),
            updatedDate: DateTime.now(),
          ),
    );

    if (truck.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Truck Details')),
        body: const Center(
          child: Text('Truck record not found.',
              style: TextStyle(color: AppTheme.textSecondary)),
        ),
      );
    }

    final wagon = truck.wagonId == null
        ? null
        : wagonState.wagons.cast<Wagon?>().firstWhere(
              (candidate) => candidate?.id == truck.wagonId,
              orElse: () => null,
            );
    final inventory =
        wagon == null ? null : ref.watch(wagonInventoryProvider(wagon.id));

    // Completed/dispatched trucks can still be corrected until archived.
    // Archiving is the explicit point at which layer editing is locked.
    // Archived records stay closed for operational actions, but the Digital
    // Register provides an audit-correction path for layer notes/deletions.
    final isWorkflowReadOnly = truck.isArchived;
    final isLayerReadOnly = truck.isArchived && !allowArchivedEditing;
    final canEditOrDelete = !truck.isArchived || allowArchivedEditing;
    final canDelete = !truck.isArchived;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
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
        title: const Text('Truck Details'),
        actions: [
          if (canEditOrDelete)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Truck Details',
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (ctx) => TruckFormDialog(
                    existingTruck: truck,
                    allowArchivedEdit: allowArchivedEditing,
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.assessment_outlined),
            tooltip: 'Generate Report',
            onPressed: () => _showUnifiedReportDialog(context, ref, truckId),
          ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Delete Truck',
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext ctx) => StrictActionWarningDialog(
                    title: 'Remove Truck?',
                    content:
                        'This removes the truck and all its layers from active views and future reports. The action is recorded for audit.',
                    expectedConfirmationText: truck.truckNumber,
                    actionLabel: 'Delete',
                    actionColor: Colors.redAccent,
                    onConfirm: () async {
                      await notifier.deleteTruck(truck.id);
                      if (context.mounted) {
                        context.pop();
                      }
                    },
                  ),
                );
              },
            ),
          const SizedBox(width: 4),
        ],
      ),

      body: SafeArea(
          child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── 1. Header Card ─────────────────────────────────────────
                TruckHeader(truck: truck),
                if (wagon != null && wagon.items.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  WagonInventoryCard(
                    wagon: wagon,
                    loadedByItem: inventory?.valueOrNull ?? const {},
                    isLoading: inventory?.isLoading ?? false,
                  ),
                ],
                const SizedBox(height: 20),

                Row(
                  children: [
                    SummaryStatCard(
                      label: 'Layers',
                      value: truck.totalLayers,
                      icon: Icons.layers_outlined,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 10),
                    SummaryStatCard(
                      label: 'Cartons',
                      value: truck.totalCartons,
                      icon: Icons.inventory_2_outlined,
                      color: AppTheme.warningColor,
                    ),
                    const SizedBox(width: 10),
                    SummaryStatCard(
                      label: 'Defects',
                      value: truck.totalDefects,
                      icon: Icons.warning_amber_outlined,
                      color: AppTheme.errorColor,
                      isAlert: true,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── 2. Layer Timeline ───────────────────────────────────────
                _SectionHeader(
                  icon: Icons.history_outlined,
                  title: 'Layer History',
                  trailing: '${layerState.layers.length} records',
                ),
                const SizedBox(height: 12),

                if (layerState.isLoading && layerState.layers.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (layerState.layers.isEmpty)
                  const _EmptyLayersState()
                else
                  LayerTimeline(
                    layers: layerState.layers,
                    isReadOnly: isLayerReadOnly,
                    onEditNotes: (layer) => _editLayerDialog(
                      context,
                      layerNotifier,
                      layer,
                      wagon: wagon,
                      loadedByItem: inventory?.valueOrNull ?? const {},
                      requireCorrectionReason: allowArchivedEditing,
                    ),
                    onDeleteLayer: (layer) {
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => StrictActionWarningDialog(
                          title: 'Remove Layer ${layer.layerNumber}?',
                          content:
                              'This voids the layer, removes it from reports, and recalculates the truck and session totals.',
                          expectedConfirmationText:
                              layer.layerNumber.toString(),
                          actionLabel: 'Remove Layer',
                          actionColor: Colors.redAccent,
                          onConfirm: () async {
                            await layerNotifier.deleteLayer(layer.id);
                          },
                        ),
                      );
                    },
                  ),

                // bottom padding for sticky bar
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      )),

      // ── 6. Sticky Bottom Action Bar ─────────────────────────────────────
      // Digital Register is a history workspace, not an operational workflow.
      // Hide loading/archive controls when a truck is opened from the register.
      bottomNavigationBar: allowArchivedEditing
          ? null
          : _StickyBottomBar(
              isReadOnly: isWorkflowReadOnly,
              hasActiveSession: sessionState.activeSession?.truckId == truckId,
              onStartSession: () async {
                final error = await sessionNotifier.startSession(
                    truckId: truckId, warehouseId: truck.warehouse);
                if (error != null && context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(error)));
                }
              },
              onCapture: isWorkflowReadOnly
                  ? null
                  : () => context.push('/trucks/$truckId/camera'),
              onComplete: !isWorkflowReadOnly && layerState.layers.isNotEmpty
                  ? () => _confirmComplete(
                      context, notifier, sessionNotifier, truck)
                  : null,
              onArchive:
                  truck.status == TruckStatus.completed && !truck.isArchived
                      ? () => _confirmArchive(context, notifier, truck)
                      : null,
            ),
    );
  }

  void _showUnifiedReportDialog(
      BuildContext context, WidgetRef ref, String truckId) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (_) => GenerateReportDialog(
        title: 'Generate Truck Report',
        subtitle:
            'Export layer scans, carton totals, notes, and defect records for this truck.',
        onPdf: () => _exportTruckReport(context, ref, truckId, 'PDF'),
        onExcel: () => _exportTruckReport(context, ref, truckId, 'Excel'),
      ),
    );
  }

  Future<void> _exportTruckReport(
      BuildContext context, WidgetRef ref, String truckId, String type) async {
    try {
      final file = type == 'PDF'
          ? await ref
              .read(pdfReportServiceProvider)
              .generateTruckReport(truckId: truckId)
          : await ref
              .read(excelReportServiceProvider)
              .generateTruckReport(truckId: truckId);
      await ref
          .read(shareServiceProvider)
          .shareFile(file, subject: 'Truck Loading Report ($type)');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  // ignore: unused_element
  void _showReportDialog(BuildContext context, WidgetRef ref, String truckId) {
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
                  spreadRadius: 2),
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
                      colors: [Color(0xFF102A43), Color(0xFF173D5C)]),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.assessment_outlined,
                          color: AppTheme.primaryColor, size: 25),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Generate Report',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          SizedBox(height: 3),
                          Text('Export this truck loading record',
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close,
                            color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                        'Choose a format. The report includes layer scans, carton totals, notes, and defect records.',
                        style: TextStyle(
                            color: AppTheme.textSecondary, height: 1.4)),
                    const SizedBox(height: 18),
                    _ReportFormatButton(
                      icon: Icons.table_chart_outlined,
                      title: 'Excel Spreadsheet',
                      subtitle: 'Best for editing and analysis',
                      color: AppTheme.successColor,
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          final file = await ref
                              .read(excelReportServiceProvider)
                              .generateTruckReport(truckId: truckId);
                          await ref.read(shareServiceProvider).shareFile(file,
                              subject: 'Truck Loading Report (Excel)');
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed: $e')));
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _ReportFormatButton(
                      icon: Icons.picture_as_pdf_outlined,
                      title: 'PDF Document',
                      subtitle: 'Best for printing and sharing',
                      color: AppTheme.primaryColor,
                      onPressed: () async {
                        Navigator.pop(ctx);
                        try {
                          final file = await ref
                              .read(pdfReportServiceProvider)
                              .generateTruckReport(truckId: truckId);
                          await ref.read(shareServiceProvider).shareFile(file,
                              subject: 'Truck Loading Report (PDF)');
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed: $e')));
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

  void _editLayerDialog(
      BuildContext context, LayerListNotifier notifier, LayerRecord layer,
      {required bool requireCorrectionReason,
      required Wagon? wagon,
      required Map<String, int> loadedByItem}) {
    final cartonController =
        TextEditingController(text: layer.cartonCount.toString());
    final defectController =
        TextEditingController(text: layer.defectCount.toString());
    final notesController = TextEditingController(text: layer.notes);
    final reasonController = TextEditingController();
    final existingByItem = {
      for (final allocation in layer.itemAllocations)
        allocation.itemName: allocation.quantity,
    };
    final itemControllers = {
      for (final item in wagon?.items ?? const <WagonItem>[])
        item.name: TextEditingController(
          text: (existingByItem[item.name] ?? 0) == 0
              ? ''
              : '${existingByItem[item.name]}',
        ),
    };
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final itemValues = {
            for (final entry in itemControllers.entries)
              entry.key: int.tryParse(entry.value.text.trim()) ?? 0,
          };
          final allocated =
              itemValues.values.fold<int>(0, (sum, quantity) => sum + quantity);
          return AlertDialog(
            title: Text('Correct Layer #${layer.layerNumber}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: cartonController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setDialogState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Carton count',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (wagon != null && wagon.items.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Item breakdown',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 4),
                    ...wagon.items.map((item) {
                      final currentLayerQuantity =
                          existingByItem[item.name] ?? 0;
                      final available = item.quantity -
                          (loadedByItem[item.name] ?? 0) +
                          currentLayerQuantity;
                      final entered = itemValues[item.name] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TextField(
                          controller: itemControllers[item.name],
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setDialogState(() {}),
                          decoration: InputDecoration(
                            labelText: item.name,
                            suffixText: '$available available',
                            errorText: entered > available
                                ? 'Maximum $available'
                                : null,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Text(
                      'Assigned items: $allocated cartons',
                      style: TextStyle(
                        color: allocated ==
                                (int.tryParse(cartonController.text.trim()) ??
                                    -1)
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: defectController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Defect count',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Operator notes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: requireCorrectionReason
                          ? 'Correction reason (required)'
                          : 'Correction reason',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  final cartons = int.tryParse(cartonController.text.trim());
                  final defects = int.tryParse(defectController.text.trim());
                  final countChanged = cartons != layer.cartonCount ||
                      defects != layer.defectCount;
                  final nextAllocations = itemValues.entries
                      .where((entry) => entry.value > 0)
                      .map((entry) => LayerItemAllocation(
                          itemName: entry.key, quantity: entry.value))
                      .toList();
                  final allocationsChanged =
                      nextAllocations.length != layer.itemAllocations.length ||
                          nextAllocations.any((next) =>
                              existingByItem[next.itemName] != next.quantity);
                  final reason = reasonController.text.trim();
                  if (cartons == null || defects == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('Enter valid carton and defect counts.')));
                    return;
                  }
                  if (wagon != null && allocated != cartons) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Item quantities must total exactly $cartons cartons.')));
                    return;
                  }
                  if ((requireCorrectionReason ||
                          countChanged ||
                          allocationsChanged) &&
                      reason.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Enter a reason for this correction.')));
                    return;
                  }
                  if (!countChanged &&
                      !allocationsChanged &&
                      !requireCorrectionReason) {
                    await notifier.editNotes(
                      layer.id,
                      notesController.text.trim().isEmpty
                          ? null
                          : notesController.text.trim(),
                    );
                  } else {
                    final error = await notifier.correctLayer(
                      layerId: layer.id,
                      cartonCount: cartons,
                      defectCount: defects,
                      notes: notesController.text.trim().isEmpty
                          ? null
                          : notesController.text.trim(),
                      itemAllocations: nextAllocations,
                      reason: reason,
                    );
                    if (error != null && context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(error)));
                      return;
                    }
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Save Correction'),
              ),
            ],
          );
        },
      ),
    ).whenComplete(() {
      cartonController.dispose();
      defectController.dispose();
      notesController.dispose();
      reasonController.dispose();
      for (final controller in itemControllers.values) {
        controller.dispose();
      }
    });
  }

  Widget _buildMetricSub(String label, String value, {bool isAlert = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
        Text(
          value,
          style: TextStyle(
            color: isAlert ? AppTheme.errorColor : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _confirmComplete(
    BuildContext context,
    TruckListNotifier notifier,
    ActiveSessionNotifier sessionNotifier,
    Truck truck,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Loading Session?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Are you sure you want to complete this truck session? It will be locked as read-only.',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            _buildMetricSub('Total Layers', '${truck.totalLayers}'),
            const SizedBox(height: 8),
            _buildMetricSub('Total Cartons', '${truck.totalCartons}'),
            const SizedBox(height: 8),
            _buildMetricSub('Total Defects', '${truck.totalDefects}',
                isAlert: truck.totalDefects > 0),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Continue Loading')),
          ElevatedButton(
            onPressed: () async {
              await sessionNotifier
                  .completeSession(); // This auto-updates the truck status
              if (context.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _confirmArchive(
    BuildContext context,
    TruckListNotifier notifier,
    Truck truck,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => ActionWarningDialog(
        title: 'Archive Session?',
        content:
            'This truck will leave the active loading view and remain in Digital Registers. Operational loading is locked, while controlled corrections remain available there.',
        actionLabel: 'Archive',
        actionColor: AppTheme.textSecondary,
        onConfirm: () {
          notifier.archiveTruck(truck.id).then((_) {
            if (context.mounted) {
              context.go('/wagons');
            }
          });
        },
      ),
    );
  }
}

// ─── Supporting private widgets ──────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;

  const _SectionHeader(
      {required this.icon, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
      ],
    );
  }
}

class _ReportFormatButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onPressed;

  const _ReportFormatButton({
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

class _EmptyLayersState extends StatelessWidget {
  const _EmptyLayersState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warehouse_outlined,
              size: 64, color: AppTheme.primaryColor.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text(
            'No Layers Captured',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start your first AI scan to begin the\nloading session.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _StickyBottomBar extends StatelessWidget {
  static const double _actionHeight = 56;
  final bool isReadOnly;
  final bool hasActiveSession;
  final VoidCallback? onStartSession;
  final VoidCallback? onCapture;
  final VoidCallback? onComplete;
  final VoidCallback? onArchive;

  const _StickyBottomBar({
    required this.isReadOnly,
    required this.hasActiveSession,
    required this.onStartSession,
    required this.onCapture,
    required this.onComplete,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
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
                label: const Text('Archive Truck',
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
                    onPressed: isReadOnly
                        ? null
                        : (hasActiveSession ? onCapture : onStartSession),
                    icon: Icon(
                        hasActiveSession
                            ? Icons.camera_alt_outlined
                            : Icons.play_circle_outline,
                        size: 20),
                    label: Text(
                      isReadOnly
                          ? 'Session Closed'
                          : (hasActiveSession
                              ? 'Capture Layer'
                              : 'Start Loading'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isReadOnly
                          ? AppTheme.dividerColor
                          : AppTheme.primaryColor,
                      foregroundColor:
                          isReadOnly ? AppTheme.textSecondary : Colors.white,
                      minimumSize: const Size.fromHeight(_actionHeight),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: _actionHeight,
                  height: _actionHeight,
                  child: IconButton(
                    onPressed: onComplete,
                    tooltip: 'Complete Loading Session',
                    icon: const Icon(Icons.check_rounded, size: 27),
                    style: IconButton.styleFrom(
                      backgroundColor: onComplete == null
                          ? AppTheme.dividerColor
                          : AppTheme.successColor,
                      foregroundColor: onComplete == null
                          ? AppTheme.textSecondary
                          : Colors.white,
                      side: BorderSide(
                        color: onComplete == null
                            ? AppTheme.textSecondary.withValues(alpha: 0.55)
                            : AppTheme.successColor,
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
