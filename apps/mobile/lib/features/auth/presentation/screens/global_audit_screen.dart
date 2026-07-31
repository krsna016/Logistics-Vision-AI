import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_theme.dart';
import '../providers/auth_providers.dart';
import '../widgets/audit_timeline.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class GlobalAuditScreen extends ConsumerWidget {
  const GlobalAuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditAsync = ref.watch(globalAuditProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Audit Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final logs = await ref.read(globalAuditProvider.future);
              if (logs.isEmpty) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No logs to export')));
                }
                return;
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exporting logs to CSV...')));
              }

              try {
                final List<List<dynamic>> rows = [
                  [
                    'Timestamp',
                    'User ID',
                    'User Name',
                    'Role',
                    'Action',
                    'Status',
                    'Details',
                    'Device'
                  ]
                ];

                for (final log in logs) {
                  rows.add([
                    log.timestamp.toIso8601String(),
                    log.userId,
                    log.userName,
                    log.userRole.name,
                    log.action,
                    log.isSuccess ? 'Success' : 'Failed',
                    log.details,
                    log.deviceName,
                  ]);
                }

                final csvData = csv.encode(rows);
                final dir = await getApplicationDocumentsDirectory();
                final file = File(
                    '${dir.path}/audit_logs_${DateTime.now().millisecondsSinceEpoch}.csv');
                await file.writeAsString(csvData);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Exported to: ${file.path}'),
                      backgroundColor: AppTheme.successColor,
                      duration: const Duration(seconds: 4)));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Export failed: $e'),
                      backgroundColor: AppTheme.errorColor));
                }
              }
            },
          ),
        ],
      ),
      body: auditAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(
                child: Text('No audit logs available.',
                    style: TextStyle(color: AppTheme.textSecondary)));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AuditTimeline(logs: logs),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
            child: Text('Failed to load audit logs',
                style: TextStyle(color: AppTheme.errorColor))),
      ),
    );
  }
}
