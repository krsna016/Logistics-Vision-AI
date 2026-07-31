import 'package:flutter/material.dart';
import '../../domain/entities/backup_archive.dart';
import '../../../../theme/app_theme.dart';

class BackupCard extends StatelessWidget {
  final BackupArchive backup;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const BackupCard({
    super.key,
    required this.backup,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    backup.isAutomatic ? Icons.auto_mode : Icons.save,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            backup.isAutomatic
                                ? 'Auto Backup'
                                : 'Manual Backup',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          if (backup.isEncrypted)
                            const Icon(Icons.lock,
                                size: 14, color: AppTheme.successColor),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${backup.createdAt.toLocal().toString().split('.')[0]} • v${backup.version}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${backup.sizeMB} MB',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          backup.status.isValid
                              ? Icons.check_circle
                              : Icons.error,
                          size: 12,
                          color: backup.status.isValid
                              ? AppTheme.successColor
                              : AppTheme.errorColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          backup.status.label,
                          style: TextStyle(
                            color: backup.status.isValid
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: AppTheme.errorColor),
                  label: const Text('Delete',
                      style: TextStyle(color: AppTheme.errorColor)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: backup.status.isValid ? onRestore : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warningColor.withOpacity(0.2),
                    foregroundColor: AppTheme.warningColor,
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.restore, size: 18),
                  label: const Text('Restore Data'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
