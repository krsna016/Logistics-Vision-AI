import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/digital_register.dart';

class SummarySection extends StatelessWidget {
  final DigitalRegister register;

  const SummarySection({super.key, required this.register});

  @override
  Widget build(BuildContext context) {
    final hours = register.loadingDuration.inHours;
    final mins = register.loadingDuration.inMinutes.remainder(60);
    final durationStr = '${hours}h ${mins}m';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Operational Summary',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildMetricCard('Total Trucks', '${register.totalTrucks}',
                  Icons.local_shipping_outlined, AppTheme.primaryColor),
              const SizedBox(width: 8),
              _buildMetricCard('Total Layers', '${register.totalLayers}',
                  Icons.layers_outlined, AppTheme.warningColor),
              const SizedBox(width: 8),
              _buildMetricCard('Total Cartons', '${register.totalCartons}',
                  Icons.inventory_2_outlined, AppTheme.successColor),
              const SizedBox(width: 8),
              _buildMetricCard('Defects', '${register.totalDefects}',
                  Icons.warning_amber_outlined, AppTheme.errorColor),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppTheme.dividerColor),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetaRow(
                  Icons.timer_outlined, 'Loading Duration', durationStr),
              _buildMetaRow(Icons.history_toggle_off, 'Generated',
                  _formatDateTime(register.generatedAt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 8,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text('$label: ',
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} $h:$m';
  }
}
