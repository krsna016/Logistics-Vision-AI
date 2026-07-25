import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

enum AIStatusType {
  aiReady,
  aiOffline,
  modelUpdating,
  cameraUnavailable;

  String get label {
    switch (this) {
      case AIStatusType.aiReady:
        return 'AI Ready';
      case AIStatusType.aiOffline:
        return 'AI Offline';
      case AIStatusType.modelUpdating:
        return 'Updating';
      case AIStatusType.cameraUnavailable:
        return 'Cam N/A';
    }
  }

  Color get color {
    switch (this) {
      case AIStatusType.aiReady:
        return AppTheme.successColor;
      case AIStatusType.aiOffline:
        return AppTheme.warningColor;
      case AIStatusType.modelUpdating:
        return AppTheme.primaryColor;
      case AIStatusType.cameraUnavailable:
        return AppTheme.errorColor;
    }
  }

  IconData get icon {
    switch (this) {
      case AIStatusType.aiReady:
        return Icons.auto_awesome;
      case AIStatusType.aiOffline:
        return Icons.cloud_off;
      case AIStatusType.modelUpdating:
        return Icons.sync;
      case AIStatusType.cameraUnavailable:
        return Icons.videocam_off;
    }
  }
}

class StatusBadge extends StatelessWidget {
  final AIStatusType status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: compact ? 10 : 12, color: status.color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontSize: compact ? 9 : 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
