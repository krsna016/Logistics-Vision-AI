import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class ActionMenuItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const ActionMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });
}

class ActionMenu extends StatelessWidget {
  final List<ActionMenuItem> items;
  final String tooltip;

  const ActionMenu({
    super.key,
    required this.items,
    this.tooltip = 'More Options',
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ActionMenuItem>(
      tooltip: tooltip,
      icon: const Icon(Icons.more_vert, color: Colors.white),
      color: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.dividerColor),
      ),
      onSelected: (item) => item.onTap(),
      itemBuilder: (context) => items.map((item) {
        final color = item.isDestructive ? AppTheme.errorColor : Colors.white;
        return PopupMenuItem<ActionMenuItem>(
          value: item,
          child: Row(
            children: [
              Icon(item.icon, size: 18, color: color),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: TextStyle(
                  color: color,
                  fontWeight: item.isDestructive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
