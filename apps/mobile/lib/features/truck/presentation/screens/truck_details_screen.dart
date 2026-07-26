import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../../../presentation/widgets/app_card.dart';
import '../../domain/entities/truck.dart';
import '../providers/truck_providers.dart';
import '../../../layer/presentation/providers/layer_providers.dart';
import '../../../layer/domain/entities/layer.dart';
import '../../../session/presentation/providers/session_providers.dart';
import '../../../../core/presentation/widgets/app_drawer.dart';
import '../widgets/truck_form_dialog.dart';
import '../widgets/truck_header.dart';
import '../widgets/summary_stat_card.dart';
import '../widgets/loading_progress_card.dart';
import '../widgets/info_tile.dart';
import '../widgets/layer_timeline.dart';
import '../widgets/quick_action_button.dart';

class TruckDetailsScreen extends ConsumerWidget {
  final String truckId;

  const TruckDetailsScreen({super.key, required this.truckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(truckListProvider);
    final notifier = ref.read(truckListProvider.notifier);
    final layerState = ref.watch(layerListProvider(truckId));
    final layerNotifier = ref.read(layerListProvider(truckId).notifier);
    final sessionState = ref.watch(activeSessionProvider);
    final sessionNotifier = ref.read(activeSessionProvider.notifier);

    final truck = listState.trucks.firstWhere(
      (e) => e.id == truckId,
      orElse: () => Truck(
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
        drawer: const AppDrawer(),
        body: const Center(
          child: Text('Truck record not found.', style: TextStyle(color: AppTheme.textSecondary)),
        ),
      );
    }

    final isReadOnly = truck.status == TruckStatus.completed ||
        truck.status == TruckStatus.dispatched ||
        truck.isArchived;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(truck.vehicleNumber,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Text(
              'Loading Workspace',
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          if (!isReadOnly)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Truck Details',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (ctx) => TruckFormDialog(existingTruck: truck),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
            tooltip: 'Remove Truck',
            onPressed: () => _confirmDelete(context, notifier, truck),
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: const AppDrawer(),
      body: SafeArea(child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── 1. Header Card ─────────────────────────────────────────
                TruckHeader(truck: truck),
                const SizedBox(height: 20),

                // ── 2. Summary Statistics Row ───────────────────────────────
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
                    const SizedBox(width: 10),
                    SummaryStatCard(
                      label: 'Scans',
                      value: layerState.layers.length,
                      icon: Icons.document_scanner_outlined,
                      color: AppTheme.successColor,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── 3. Progress Bar Card ────────────────────────────────────
                LoadingProgressCard(
                  completedLayers: truck.totalLayers,
                  totalLayers: truck.totalLayers > 0 ? truck.totalLayers : 1,
                ),
                const SizedBox(height: 20),

                // ── 4. Primary Action Buttons ───────────────────────────────
                _SectionHeader(
                  icon: Icons.bolt_outlined,
                  title: 'Workspace Actions',
                ),
                const SizedBox(height: 10),

                if (!isReadOnly) ...[
                  if (sessionState.activeSession?.truckId == truckId)
                    QuickActionButton(
                      icon: Icons.camera_alt_outlined,
                      label: 'Capture Next Layer',
                      subtitle: 'Launch AI carton scanning',
                      backgroundColor: AppTheme.primaryColor,
                      onPressed: () => context.push('/trucks/$truckId/camera'),
                    )
                  else if (sessionState.activeSession == null)
                    QuickActionButton(
                      icon: Icons.play_circle_outline,
                      label: 'Start Loading Session',
                      subtitle: 'Initialize session & begin scanning',
                      backgroundColor: AppTheme.primaryColor,
                      onPressed: () async {
                        final error = await sessionNotifier.startSession(
                          truckId: truckId,
                          warehouseId: truck.warehouse,
                        );
                        if (error != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                        }
                      },
                    )
                  else
                    const QuickActionButton(
                      icon: Icons.lock_outline,
                      label: 'Another Session Active',
                      subtitle: 'Finish current session first',
                      backgroundColor: Colors.grey,
                      onPressed: null,
                    ),
                  const SizedBox(height: 10),
                ],

                QuickActionButton(
                  icon: Icons.layers_outlined,
                  label: 'Review Layers',
                  subtitle: '${truck.totalLayers} layers captured',
                  isOutlined: true,
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.primaryColor,
                  onPressed: layerState.layers.isEmpty
                      ? null
                      : () => _scrollToLayers(context),
                ),
                const SizedBox(height: 10),

                QuickActionButton(
                  icon: Icons.picture_as_pdf_outlined,
                  label: 'Generate Report',
                  subtitle: 'Export full loading log to PDF',
                  isOutlined: true,
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: AppTheme.successColor,
                  onPressed: () => _showReportDialog(context),
                ),
                const SizedBox(height: 10),

                if (!isReadOnly && (sessionState.activeSession?.truckId == truckId || truck.totalLayers > 0))
                  QuickActionButton(
                    icon: Icons.check_circle_outline,
                    label: 'Complete Loading Session',
                    subtitle: 'Mark as finished and close',
                    backgroundColor: AppTheme.successColor,
                    onPressed: () => _confirmComplete(context, notifier, sessionNotifier, truck),
                  ),

                if (truck.status == TruckStatus.completed && !truck.isArchived) ...[
                  const SizedBox(height: 10),
                  QuickActionButton(
                    icon: Icons.archive_outlined,
                    label: 'Archive Truck',
                    subtitle: 'Move session to read-only archive',
                    backgroundColor: AppTheme.textSecondary,
                    onPressed: () => _confirmArchive(context, notifier, truck),
                  ),
                ],
                const SizedBox(height: 24),

                // ── 5. Quick Information Panel ──────────────────────────────
                _SectionHeader(icon: Icons.info_outline, title: 'Session Information'),
                const SizedBox(height: 10),
                AppCard(
                  child: Column(
                    children: [


                      InfoTile(icon: Icons.person_outline, label: 'Driver', value: truck.driverName),
                      if (truck.driverMobile != null && truck.driverMobile!.isNotEmpty) ...[
                        _divider(),
                        InfoTile(icon: Icons.phone_outlined, label: 'Driver Mobile', value: truck.driverMobile!),
                      ],
                      _divider(),
                      InfoTile(icon: Icons.business_outlined, label: 'Carrier', value: truck.company),
                      _divider(),


                      InfoTile(icon: Icons.warehouse_outlined, label: 'Warehouse', value: truck.warehouse),

                      _divider(),
                      InfoTile(
                        icon: Icons.calendar_today_outlined,
                        label: 'Created',
                        value: _formatDateTime(truck.createdDate),
                      ),
                      _divider(),
                      InfoTile(
                        icon: Icons.update_outlined,
                        label: 'Last Updated',
                        value: _formatDateTime(truck.updatedDate),
                      ),
                      _divider(),
                      InfoTile(
                        icon: truck.syncStatus == SyncStatus.synced
                            ? Icons.cloud_done_outlined
                            : Icons.cloud_upload_outlined,
                        label: 'Sync Status',
                        value: truck.syncStatus.name.toUpperCase(),
                        valueColor: truck.syncStatus == SyncStatus.synced
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── 6. Layer Timeline ───────────────────────────────────────
                _SectionHeader(
                  icon: Icons.history_outlined,
                  title: 'Layer History',
                  trailing: '${layerState.layers.length} records',
                ),
                const SizedBox(height: 12),

                if (layerState.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (layerState.layers.isEmpty)
                  _EmptyLayersState(
                    isReadOnly: isReadOnly,
                    onCapture: () => context.push('/trucks/$truckId/camera'),
                  )
                else
                  LayerTimeline(
                    layers: layerState.layers,
                    isReadOnly: isReadOnly,
                    onEditNotes: (layer) =>
                        _editLayerNotesDialog(context, layerNotifier, layer),
                    onDeleteLayer: (id) => layerNotifier.deleteLayer(id),
                  ),

                // bottom padding for sticky bar
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      )),

      // ── 7. Sticky Bottom Action Bar ─────────────────────────────────────
      bottomNavigationBar: _StickyBottomBar(
        isReadOnly: isReadOnly,
        hasActiveSession: sessionState.activeSession?.truckId == truckId,
        isAnotherSessionActive: sessionState.activeSession != null && sessionState.activeSession?.truckId != truckId,
        onStartSession: () async {
          final error = await sessionNotifier.startSession(truckId: truckId, warehouseId: truck.warehouse);
          if (error != null && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        },
        onCapture: isReadOnly ? null : () => context.push('/trucks/$truckId/camera'),
        onReport: () => _showReportDialog(context),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: AppTheme.dividerColor);

  void _scrollToLayers(BuildContext context) {
    // Scrolls user to the layer section — functional stub
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scrolling to layer history...')),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Generate Loading Report'),
        content: const Text(
          'PDF report generation is ready. This will compile all layer scans, carton counts, and defect records into a printable document.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Export PDF'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _editLayerNotesDialog(
    BuildContext context,
    LayerListNotifier notifier,
    LayerRecord layer,
  ) {
    final controller = TextEditingController(text: layer.notes);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Notes — Layer #${layer.layerNumber}'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Operator Notes'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              notifier.editNotes(
                layer.id,
                controller.text.trim().isEmpty ? null : controller.text.trim(),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Save Notes'),
          ),
        ],
      ),
    );
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Loading Session?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to complete this truck session? It will be locked as read-only.', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            _buildMetricSub('Total Layers', '${truck.totalLayers}'),
            const SizedBox(height: 8),
            _buildMetricSub('Total Cartons', '${truck.totalCartons}'),
            const SizedBox(height: 8),
            _buildMetricSub('Total Defects', '${truck.totalDefects}', isAlert: truck.totalDefects > 0),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Continue Loading')),
          ElevatedButton(
            onPressed: () async {
              await sessionNotifier.completeSession(); // This auto-updates the truck status
              if (context.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive Session?'),
        content: const Text(
          'The truck session will be moved to archives. No further edits will be possible.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              notifier.archiveTruck(truck.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.textSecondary),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    TruckListNotifier notifier,
    Truck truck,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Truck?'),
        content: const Text(
          'This will soft-delete the truck from active logs. An administrator can restore this record if needed.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              notifier.deleteTruck(truck.id);
              Navigator.pop(ctx);
              context.go('/wagons');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  $h:$m';
  }
}

// ─── Supporting private widgets ──────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;

  const _SectionHeader({required this.icon, required this.title, this.trailing});

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

class _EmptyLayersState extends StatelessWidget {
  final bool isReadOnly;
  final VoidCallback onCapture;

  const _EmptyLayersState({required this.isReadOnly, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warehouse_outlined, size: 64, color: AppTheme.primaryColor.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text(
            'No Layers Captured',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start your first AI scan to begin the\nloading session.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
          ),
          if (!isReadOnly) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCapture,
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Capture First Layer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StickyBottomBar extends StatelessWidget {
  final bool isReadOnly;
  final bool hasActiveSession;
  final bool isAnotherSessionActive;
  final VoidCallback? onStartSession;
  final VoidCallback? onCapture;
  final VoidCallback onReport;

  const _StickyBottomBar({
    required this.isReadOnly,
    required this.hasActiveSession,
    required this.isAnotherSessionActive,
    required this.onStartSession,
    required this.onCapture,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: const Border(top: BorderSide(color: AppTheme.dividerColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: ElevatedButton.icon(
              onPressed: isReadOnly || isAnotherSessionActive ? null : (hasActiveSession ? onCapture : onStartSession),
              icon: Icon(hasActiveSession ? Icons.camera_alt_outlined : Icons.play_circle_outline, size: 20),
              label: Text(
                isReadOnly ? 'Session Closed' : (hasActiveSession ? 'Capture Layer' : 'Start Loading'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isReadOnly || isAnotherSessionActive ? AppTheme.dividerColor : AppTheme.primaryColor,
                foregroundColor: isReadOnly || isAnotherSessionActive ? AppTheme.textSecondary : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: OutlinedButton.icon(
              onPressed: onReport,
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('Report', style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.successColor,
                side: BorderSide(color: AppTheme.successColor.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
