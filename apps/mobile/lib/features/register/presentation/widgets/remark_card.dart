import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class RemarkCard extends StatelessWidget {
  final String? remarks;
  final VoidCallback onEdit;

  const RemarkCard({
    super.key,
    required this.remarks,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.edit_note_outlined, color: AppTheme.warningColor, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Operational Remarks',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: AppTheme.primaryColor),
                onPressed: onEdit,
                tooltip: 'Edit Remarks',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            remarks != null && remarks!.isNotEmpty ? remarks! : 'No remarks recorded for this wagon session.',
            style: TextStyle(
              color: remarks != null && remarks!.isNotEmpty ? Colors.white : AppTheme.textSecondary,
              fontStyle: remarks != null && remarks!.isNotEmpty ? FontStyle.normal : FontStyle.italic,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
