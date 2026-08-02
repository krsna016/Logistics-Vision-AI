import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../truck/domain/entities/truck.dart';

class TruckTable extends StatelessWidget {
  final List<Truck> trucks;
  final ValueChanged<Truck>? onTruckTap;

  const TruckTable({super.key, required this.trucks, this.onTruckTap});

  @override
  Widget build(BuildContext context) {
    final totalLayers = trucks.fold(0, (sum, t) => sum + t.totalLayers);
    final totalCartons = trucks.fold(0, (sum, t) => sum + t.totalCartons);
    final totalDefects = trucks.fold(0, (sum, t) => sum + t.totalDefects);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Wagon Cargo Manifest',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppTheme.cardColor),
              columns: const [
                DataColumn(
                    label: Text('TRUCK NUMBER',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('DRIVER',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('CARRIER',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold))),
                DataColumn(
                    numeric: true,
                    label: Text('LAYERS',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold))),
                DataColumn(
                    numeric: true,
                    label: Text('CARTONS',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold))),
                DataColumn(
                    numeric: true,
                    label: Text('DEFECTS',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('STATUS',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('COMPLETED',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold))),
              ],
              rows: [
                ...trucks.map((truck) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(truck.truckNumber,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        onTap: onTruckTap == null
                            ? null
                            : () => onTruckTap!(truck),
                      ),
                      DataCell(Text(truck.driverName)),
                      DataCell(Text(truck.company)),
                      DataCell(Text('${truck.totalLayers}')),
                      DataCell(Text('${truck.totalCartons}',
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(
                        Text(
                          '${truck.totalDefects}',
                          style: TextStyle(
                            color: truck.totalDefects > 0
                                ? AppTheme.errorColor
                                : AppTheme.textSecondary,
                            fontWeight: truck.totalDefects > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      DataCell(_buildStatusChip(truck.status.displayName)),
                      DataCell(Text(_formatTime(truck.updatedDate))),
                    ],
                  );
                }),
                // Total Summary Row
                DataRow(
                  color: WidgetStateProperty.all(AppTheme.cardColor),
                  cells: [
                    const DataCell(Text('TOTALS',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warningColor))),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                    DataCell(Text('$totalLayers',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warningColor))),
                    DataCell(Text('$totalCartons',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warningColor))),
                    DataCell(Text('$totalDefects',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: totalDefects > 0
                                ? AppTheme.errorColor
                                : AppTheme.warningColor))),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: const TextStyle(
            color: AppTheme.successColor,
            fontSize: 10,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
