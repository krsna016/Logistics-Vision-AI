import 'package:flutter/material.dart';
import '../../domain/entities/role.dart';
import '../../../../theme/app_theme.dart';

class RoleChip extends StatelessWidget {
  final Role role;

  const RoleChip({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (role) {
      case Role.operator:
        color = Colors.blueGrey;
        break;
      case Role.supervisor:
        color = Colors.teal;
        break;
      case Role.manager:
        color = Colors.purpleAccent;
        break;
      case Role.administrator:
        color = AppTheme.errorColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role.displayName.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
