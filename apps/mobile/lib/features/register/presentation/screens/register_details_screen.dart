import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/entities/digital_register.dart';
import '../providers/register_providers.dart';
import '../widgets/register_header.dart';
import '../widgets/truck_table.dart';
import '../widgets/summary_section.dart';
import '../widgets/remark_card.dart';
import '../widgets/history_tile.dart';
import '../widgets/report_action_bar.dart';
import '../widgets/register_preview_dialog.dart';
import '../../domain/services/report_exporter.dart';

class RegisterDetailsScreen extends ConsumerWidget {
  final String registerId;

  const RegisterDetailsScreen({super.key, required this.registerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerListProvider);
    final notifier = ref.read(registerListProvider.notifier);

    final DigitalRegister register = state.registers.firstWhere(
      (r) => r.id == registerId || r.wagonId == registerId,
      orElse: () => state.registers.isNotEmpty ? state.registers.first : throw Exception('Register not found'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${register.wagonNumber} — Digital Register'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () => _showPreview(context, register, notifier),
            tooltip: 'Print Preview',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            RegisterHeader(register: register),
            const SizedBox(height: 16),

            // Summary Section
            SummarySection(register: register),
            const SizedBox(height: 16),

            // Action Bar
            ReportActionBar(
              onExport: (type) => _handleExport(context, register.id, type, notifier),
              onPreview: () => _showPreview(context, register, notifier),
            ),
            const SizedBox(height: 16),

            // Truck Table
            TruckTable(trucks: register.trucks),
            const SizedBox(height: 16),

            // Remarks Section
            RemarkCard(
              remarks: register.remarks,
              onEdit: () => _showEditRemarksDialog(context, register.id, register.remarks, notifier),
            ),
            const SizedBox(height: 16),

            // History Section
            HistoryTile(register: register),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showPreview(BuildContext context, dynamic register, RegisterListNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => RegisterPreviewDialog(
        register: register,
        onConfirmExport: () {
          _handleExport(context, register.id, ExportType.print, notifier);
        },
      ),
    );
  }

  Future<void> _handleExport(BuildContext context, String registerId, ExportType type, RegisterListNotifier notifier) async {
    // Show Progress Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text('Generating ${type.name.toUpperCase()} Report...'),
          ],
        ),
      ),
    );

    final exporter = MockReportExporter();
    await exporter.exportRegister(registerId, type);
    await notifier.recordExport(registerId);

    if (context.mounted) {
      Navigator.pop(context); // Close progress dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${type.name.toUpperCase()} report successfully generated and saved to device!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  void _showEditRemarksDialog(BuildContext context, String registerId, String? currentRemarks, RegisterListNotifier notifier) {
    final controller = TextEditingController(text: currentRemarks);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Operational Remarks'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter notes (e.g. Delayed due to rain, Truck changed...)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.updateRemarks(registerId, controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save Remarks'),
          ),
        ],
      ),
    );
  }
}
