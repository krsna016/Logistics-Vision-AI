import 'package:flutter/material.dart';
import '../../domain/entities/sync_operation.dart';
import '../../../../theme/app_theme.dart';

class SyncQueueCard extends StatelessWidget {
  final SyncOperation item;
  final VoidCallback onResolveConflict;

  const SyncQueueCard({super.key, required this.item, required this.onResolveConflict});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;

    switch (item.status) {
      case SyncStatus.queued:
        statusColor = Colors.white54;
        statusIcon = Icons.schedule;
        break;
      case SyncStatus.syncing:
        statusColor = AppTheme.primaryColor;
        statusIcon = Icons.sync;
        break;
      case SyncStatus.completed:
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        break;
      case SyncStatus.conflict:
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.warning_amber_rounded;
        break;
      case SyncStatus.failed:
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.error_outline;
        break;
      case SyncStatus.cancelled:
        statusColor = Colors.grey;
        statusIcon = Icons.cancel_outlined;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.operation == SyncOperationType.delete ? Icons.delete_outline : Icons.cloud_upload_outlined,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.entityType} • ${item.entityId}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      item.status.subtext,
                      style: TextStyle(color: statusColor, fontSize: 11),
                    ),
                    if (item.errorMessage != null && item.errorMessage!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '- ${item.errorMessage}',
                          style: const TextStyle(color: AppTheme.errorColor, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]
                  ],
                )
              ],
            ),
          ),
          if (item.status == SyncStatus.conflict)
            ElevatedButton(
              onPressed: onResolveConflict,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warningColor.withOpacity(0.2),
                foregroundColor: AppTheme.warningColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('Resolve'),
            )
          else if (item.status == SyncStatus.failed || item.status == SyncStatus.queued)
            const Icon(Icons.more_vert, color: Colors.white24),
        ],
      ),
    );
  }
}
