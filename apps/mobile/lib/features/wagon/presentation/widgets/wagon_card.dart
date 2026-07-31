import 'package:flutter/material.dart';
import '../../../../core/presentation/layout/responsive.dart';
import '../../../../presentation/widgets/app_card.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/wagon.dart';

class WagonCard extends StatelessWidget {
  final Wagon wagon;
  final int totalCartons;
  final int totalDefects;
  final int completedTrucks;
  final int totalTrucks;
  final VoidCallback onTap;

  const WagonCard({
    super.key,
    required this.wagon,
    required this.totalCartons,
    required this.totalDefects,
    required this.completedTrucks,
    required this.totalTrucks,
    required this.onTap,
  });

  Color _getStatusColor(WagonStatus status) {
    switch (status) {
      case WagonStatus.planning:
        return AppTheme.primaryColor;
      case WagonStatus.loading:
        return AppTheme.warningColor;
      case WagonStatus.completed:
        return AppTheme.successColor;
      case WagonStatus.archived:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(wagon.status);
    final double progress =
        totalTrucks > 0 ? completedTrucks / totalTrucks : 0.0;
    final int progressPct = (progress * 100).toInt();

    return AppCard(
      elevation: 1,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Wagon Number and Status Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  wagon.wagonNumber,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppResponsive.text(context, 18),
                      letterSpacing: 0.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppResponsive.isCompact(context) ? 8 : 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  wagon.status.displayName.toUpperCase(),
                  style: TextStyle(
                      color: statusColor,
                      fontSize: AppResponsive.text(context, 10, max: 1),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.fingerprint_outlined,
                  size: 13, color: Color(0xFF7E8A99)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'ID: ${wagon.id}',
                  style: const TextStyle(
                      color: Color(0xFF7E8A99),
                      fontSize: 10,
                      fontFamily: 'monospace'),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Route Details
          Text(
            'Route: ${wagon.origin}  ➔  ${wagon.destination}',
            style: TextStyle(
              color: const Color(0xFFBDBDBD),
              fontSize: AppResponsive.text(context, 13),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Loading Date: ${_formatDate(wagon.loadingDate)}',
            style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 12),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(height: 1, color: Color(0xFF3A3A3A)),
          ),

          // Progress Bar: completedTrucks / totalTrucks
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Truck Progress: $completedTrucks / $totalTrucks expected ($progressPct%)',
                  style: TextStyle(
                    fontSize: AppResponsive.text(context, 12),
                    color: const Color(0xFFBDBDBD),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFF3A3A3A),
              valueColor: AlwaysStoppedAnimation<Color>(
                wagon.status == WagonStatus.completed
                    ? AppTheme.successColor
                    : AppTheme.primaryColor,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),

          // Bottom Stats Row: Cartons, Defects, Arrow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric('Cartons', '$totalCartons'),
              _buildMetric('Defects', '$totalDefects',
                  isAlert: totalDefects > 0),
              const Icon(Icons.arrow_forward,
                  color: Color(0xFFBDBDBD), size: 20),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, {bool isAlert = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
              fontSize: 10,
              color: Color(0xFFBDBDBD),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isAlert ? AppTheme.errorColor : Colors.white,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}
