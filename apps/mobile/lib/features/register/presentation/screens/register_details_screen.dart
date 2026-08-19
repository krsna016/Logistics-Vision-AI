import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../../../core/presentation/widgets/strict_action_warning_dialog.dart';

import '../../domain/entities/digital_register.dart';
import '../providers/register_providers.dart';
import '../../../wagon/presentation/providers/wagon_providers.dart';
import '../../../wagon/presentation/widgets/create_wagon_sheet.dart';
import '../widgets/register_header.dart';
import '../widgets/truck_table.dart';
import '../widgets/summary_section.dart';
import '../widgets/remark_card.dart';
import '../widgets/register_reconciliation_card.dart';
import '../../../reports/presentation/providers/report_providers.dart';
import '../../../reports/presentation/widgets/generate_report_dialog.dart';
import '../../../reports/domain/entities/report_export.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class RegisterDetailsScreen extends ConsumerWidget {
  final String registerId;

  const RegisterDetailsScreen({super.key, required this.registerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerListProvider);
    final notifier = ref.read(registerListProvider.notifier);
    final canModify =
        ref.watch(authProvider)?.role.canModifyDigitalRegisters ?? false;

    final DigitalRegister register = state.registers.firstWhere(
      (r) => r.id == registerId || r.wagonId == registerId,
      orElse: () => state.registers.isNotEmpty
          ? state.registers.first
          : throw Exception('Register not found'),
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
              context.push('/registers');
            }
          },
        ),
        title: Text('${register.wagonNumber} - Digital Register'),
        actions: [
          if (canModify)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Wagon Details',
              onPressed: () => _editWagon(context, ref, register.wagonId),
            ),
          IconButton(
            icon: const Icon(Icons.assessment_outlined),
            onPressed: () =>
                _showUnifiedReportDialog(context, ref, register.wagonId),
            tooltip: 'Generate Report',
          ),
          if (canModify)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _confirmDelete(context, ref, register),
              tooltip: 'Delete Wagon',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(registerListProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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

            RegisterReconciliationCard(register: register),
            const SizedBox(height: 16),

            // Truck Table
            TruckTable(
              trucks: register.trucks,
              layersByTruck: register.layersByTruck,
              onTruckTap: (truck) async {
                await context.push(
                  '/trucks/${truck.id}',
                  extra: <String, dynamic>{
                    'truck': truck,
                    'isRegisterView': true,
                    'allowArchivedEditing': canModify,
                  },
                );
                if (context.mounted) {
                  await ref.read(registerListProvider.notifier).refresh();
                }
              },
            ),
            const SizedBox(height: 16),

            // Remarks Section
            RemarkCard(
              remarks: register.remarks,
              onEdit: canModify
                  ? () => _showEditRemarksDialog(
                      context, register.id, register.remarks, notifier)
                  : null,
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 40),
          ],
        ),
      ),
      ),
    );
  }

  Future<void> _editWagon(
      BuildContext context, WidgetRef ref, String wagonId) async {
    final wagon = await ref.read(wagonRepositoryProvider).getWagonById(wagonId);
    if (!context.mounted || wagon == null) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CreateWagonSheet(existingWagon: wagon),
    );
    if (context.mounted) {
      await ref.read(registerListProvider.notifier).refresh();
    }
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, DigitalRegister register) {
    showDialog<void>(
      context: context,
      builder: (ctx) => StrictActionWarningDialog(
        title: 'Remove Wagon?',
        content:
            'This removes the wagon from the app and Digital Registers. Enter the wagon number to confirm.',
        expectedConfirmationText: register.wagonNumber,
        actionLabel: 'Delete Wagon',
        actionColor: Colors.redAccent,
        icon: Icons.delete_forever_outlined,
        onConfirm: () async {
          await ref
              .read(wagonListProvider.notifier)
              .deleteWagon(register.wagonId);
          await ref.read(registerListProvider.notifier).refresh();
          if (context.mounted) {
            context.go('/wagons');
            context.push('/registers');
          }
        },
      ),
    );
  }

  void _showUnifiedReportDialog(
      BuildContext context, WidgetRef ref, String wagonId) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (_) => GenerateReportDialog(
        title: 'Generate Digital Register Report',
        subtitle:
            'Export the complete wagon manifest, truck details, layer history, carton totals, and defect records.',
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
              .generateDigitalRegisterReport(wagonId: wagonId)
          : await ref
              .read(excelReportServiceProvider)
              .generateDigitalRegisterReport(wagonId: wagonId);
      await logGeneratedReport(
        ref,
        reportType: ReportType.audit,
        format: type == 'PDF' ? ExportFormat.pdf : ExportFormat.excel,
        status: ExportStatus.success,
        subjectId: wagonId,
        file: file,
      );
      await ref
          .read(shareServiceProvider)
          .shareFile(file, subject: 'Digital Register Report ($type)');
    } catch (e) {
      await logGeneratedReport(
        ref,
        reportType: ReportType.audit,
        format: type == 'PDF' ? ExportFormat.pdf : ExportFormat.excel,
        status: ExportStatus.failed,
        subjectId: wagonId,
        error: e.toString(),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to generate report: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showEditRemarksDialog(BuildContext context, String registerId,
      String? currentRemarks, RegisterListNotifier notifier) {
    final controller = TextEditingController(text: currentRemarks);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Operational Remarks'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText:
                'Enter notes (e.g. Delayed due to rain, Truck changed...)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: AppTheme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: AppTheme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
            ),
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

