import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_theme.dart';
import '../providers/backup_providers.dart';

class StorageCard extends ConsumerWidget {
  const StorageCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(storageStatisticsProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: statsAsync.when(
        data: (stats) {
          final dbSize = stats['dbSize'] ?? 0;
          final imagesSize = stats['imagesSize'] ?? 0;
          final backupsSize = stats['backupsSize'] ?? 0;
          final freeSpace = stats['freeSpace'] ?? 1;

          final totalUsed = dbSize + imagesSize + backupsSize;
          final totalStorage = totalUsed + freeSpace;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.storage, color: AppTheme.primaryColor),
                  SizedBox(width: 8),
                  Text('Storage Health',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    Expanded(
                        flex: (dbSize / totalStorage * 1000).toInt(),
                        child: Container(
                            height: 12, color: AppTheme.primaryColor)),
                    Expanded(
                        flex: (imagesSize / totalStorage * 1000).toInt(),
                        child: Container(
                            height: 12, color: AppTheme.warningColor)),
                    Expanded(
                        flex: (backupsSize / totalStorage * 1000).toInt(),
                        child:
                            Container(height: 12, color: Colors.purpleAccent)),
                    Expanded(
                        flex: (freeSpace / totalStorage * 1000).toInt(),
                        child: Container(height: 12, color: Colors.white10)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildLegend('Database Records', dbSize, AppTheme.primaryColor),
              const SizedBox(height: 8),
              _buildLegend('AI Images', imagesSize, AppTheme.warningColor),
              const SizedBox(height: 8),
              _buildLegend('Local Backups', backupsSize, Colors.purpleAccent),
              const SizedBox(height: 16),
              const Divider(color: Colors.white10),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Available Storage',
                      style: TextStyle(color: AppTheme.textSecondary)),
                  Text('${(freeSpace / 1024).toStringAsFixed(1)} GB Free',
                      style: const TextStyle(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Text('Failed to load stats',
            style: TextStyle(color: AppTheme.errorColor)),
      ),
    );
  }

  Widget _buildLegend(String label, double valueMB, Color color) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
        const Spacer(),
        Text(
          valueMB > 1024
              ? '${(valueMB / 1024).toStringAsFixed(2)} GB'
              : '${valueMB.toStringAsFixed(1)} MB',
          style: const TextStyle(
              color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
