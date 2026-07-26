import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum CustomStatusType { active, completed, closed }

class StatusChip extends StatelessWidget {
  final CustomStatusType type;
  final String label;

  const StatusChip({
    super.key,
    required this.type,
    required this.label,
  });

  Color get _color {
    switch (type) {
      case CustomStatusType.active:
        return AppTheme.warningColor;
      case CustomStatusType.completed:
        return AppTheme.successColor;
      case CustomStatusType.closed:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
