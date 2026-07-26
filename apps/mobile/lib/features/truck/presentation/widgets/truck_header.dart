import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/truck.dart';

/// Displays the large truck identifier header with key metadata fields.
class TruckHeader extends StatelessWidget {
  final Truck truck;

  const TruckHeader({super.key, required this.truck});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1B2A), Color(0xFF1E2D3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large Vehicle Number
          Text(
            truck.vehicleNumber,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          _StatusChip(status: truck.status),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF2A3F52), height: 1),
          const SizedBox(height: 14),

          // Metadata Grid
          _MetaRow(icon: Icons.person_outline, label: 'Driver', value: truck.driverName),
          if (truck.driverMobile != null && truck.driverMobile!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _MetaRow(icon: Icons.phone_outlined, label: 'Driver Mobile', value: truck.driverMobile!),
          ],
          const SizedBox(height: 8),
          _MetaRow(icon: Icons.business_outlined, label: 'Carrier', value: truck.company),
          const SizedBox(height: 8),


          _MetaRow(icon: Icons.warehouse_outlined, label: 'Warehouse', value: truck.warehouse),
          if (truck.wagonId != null) ...[
            const SizedBox(height: 8),
            _MetaRow(icon: Icons.train_outlined, label: 'Wagon', value: truck.wagonId!),
          ],
          const SizedBox(height: 8),
          _MetaRow(
            icon: Icons.calendar_today_outlined,
            label: 'Loading Date',
            value: _formatDate(truck.createdDate),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _StatusChip extends StatelessWidget {
  final TruckStatus status;

  const _StatusChip({required this.status});

  Color get _color {
    switch (status) {
      case TruckStatus.loading:
        return AppTheme.warningColor;
      case TruckStatus.completed:
        return AppTheme.successColor;
      case TruckStatus.dispatched:
        return AppTheme.textSecondary;
    }
  }

  IconData get _icon {
    switch (status) {
      case TruckStatus.loading:
        return Icons.local_shipping_outlined;
      case TruckStatus.completed:
        return Icons.check_circle_outline;
      case TruckStatus.dispatched:
        return Icons.archive_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: _color),
          const SizedBox(width: 6),
          Text(
            status.displayName.toUpperCase(),
            style: TextStyle(
              color: _color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
