import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/services/report_exporter.dart';

class ExportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final ExportType type;
  final VoidCallback onTap;
  final bool isPrimary;

  const ExportButton({
    super.key,
    required this.label,
    required this.icon,
    required this.type,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: AppTheme.dividerColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class ReportActionBar extends StatelessWidget {
  final void Function(ExportType type) onExport;
  final VoidCallback onPreview;

  const ReportActionBar({
    super.key,
    required this.onExport,
    required this.onPreview,
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
                  Icon(Icons.output_outlined, color: AppTheme.primaryColor, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Export & Operations',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: onPreview,
                icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                label: const Text('Print Preview', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.warningColor,
                  side: const BorderSide(color: AppTheme.warningColor),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ExportButton(
                label: 'Generate PDF',
                icon: Icons.picture_as_pdf_outlined,
                type: ExportType.pdf,
                isPrimary: true,
                onTap: () => onExport(ExportType.pdf),
              ),
              ExportButton(
                label: 'Excel (.xlsx)',
                icon: Icons.table_chart_outlined,
                type: ExportType.excel,
                onTap: () => onExport(ExportType.excel),
              ),
              ExportButton(
                label: 'CSV',
                icon: Icons.grid_on_outlined,
                type: ExportType.csv,
                onTap: () => onExport(ExportType.csv),
              ),
              ExportButton(
                label: 'Print',
                icon: Icons.print_outlined,
                type: ExportType.print,
                onTap: () => onExport(ExportType.print),
              ),
              ExportButton(
                label: 'Share',
                icon: Icons.share_outlined,
                type: ExportType.share,
                onTap: () => onExport(ExportType.share),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
