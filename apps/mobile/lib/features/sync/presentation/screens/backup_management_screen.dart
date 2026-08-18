import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_theme.dart';
import '../../../../core/presentation/widgets/app_drawer.dart';
import '../providers/backup_providers.dart';
import '../widgets/backup_card.dart';
import '../widgets/storage_card.dart';

class BackupManagementScreen extends ConsumerWidget {
  const BackupManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupsAsync = ref.watch(backupListProvider);
    final isCreatingBackup = ref.watch(backupNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Management'),
        actions: [
          const IconButton(
            icon: Icon(Icons.settings),
            onPressed: null,
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      drawerScrimColor: Colors.black.withValues(alpha: 0.86),
      endDrawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Storage Stats
            const StorageCard(),
            const SizedBox(height: 32),

            // Backup Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isCreatingBackup
                        ? null
                        : () => ref
                            .read(backupNotifierProvider.notifier)
                            .triggerManualBackup(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: isCreatingBackup
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.backup),
                    label: Text(isCreatingBackup
                        ? 'Creating Archive...'
                        : 'Create Local Backup'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppTheme.primaryColor),
                    ),
                    icon: const Icon(Icons.usb, color: AppTheme.primaryColor),
                    label: const Text('Export to USB',
                        style: TextStyle(color: AppTheme.primaryColor)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Local Backups
            const Text('LOCAL BACKUP ARCHIVES',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            const SizedBox(height: 12),
            backupsAsync.when(
              data: (backups) {
                if (backups.isEmpty) {
                  return const Center(
                      child: Text('No local backups found.',
                          style: TextStyle(color: AppTheme.textSecondary)));
                }
                return Column(
                  children: backups
                      .map((backup) => BackupCard(
                            backup: backup,
                            onDelete: () {
                              ref
                                  .read(backupRepositoryProvider)
                                  .deleteBackup(backup.id);
                              ref.invalidate(backupListProvider);
                            },
                            onRestore: () {
                              _showRestoreWarning(context, backup.id);
                            },
                          ))
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Error loading backups',
                  style: TextStyle(color: AppTheme.errorColor)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRestoreWarning(BuildContext context, String backupId) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor),
            SizedBox(width: 8),
            Text('Confirm Restore', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Restoring this backup will OVERWRITE all current operational data. Any data collected since this backup will be permanently lost if not synced to the cloud.\n\nAre you absolutely sure you want to proceed?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          Consumer(
            builder: (context, ref, child) {
              return ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final success = await ref
                      .read(backupRepositoryProvider)
                      .restoreBackup(backupId);
                  if (context.mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'Backup restored successfully! Restart app to apply changes.'),
                          backgroundColor: AppTheme.successColor,
                          duration: Duration(seconds: 5)));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Failed to restore backup.'),
                          backgroundColor: AppTheme.errorColor));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor),
                child: const Text('OVERWRITE DATA'),
              );
            },
          ),
        ],
      ),
    );
  }
}
