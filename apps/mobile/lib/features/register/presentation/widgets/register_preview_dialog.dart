import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/digital_register.dart';
import '../../../truck/domain/entities/truck.dart';

class RegisterPreviewDialog extends StatelessWidget {
  final DigitalRegister register;
  final VoidCallback onConfirmExport;

  const RegisterPreviewDialog({
    super.key,
    required this.register,
    required this.onConfirmExport,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.print_outlined, color: Colors.black87),
                    SizedBox(width: 8),
                    Text(
                      'PRINT PREVIEW — DOCUMENT VERIFICATION',
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: Colors.black26),
            
            // Printable Area Simulation (White background document)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Logo & Company
                    Row(
                      children: [
                        Image.asset('assets/images/logo.png', height: 40, fit: BoxFit.contain),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vinayak SmartLoad',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            Text(
                              'Powered by Vinayak Logistics',
                              style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Text(
                          'DIGITAL WAGON REGISTER',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.black38, thickness: 1.5),
                    const SizedBox(height: 12),

                    // Wagon Meta Table
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.grey.shade100,
                      child: Column(
                        children: [
                          _buildDocRow('Wagon Number:', register.wagonNumber, 'Loading Date:', _formatDate(register.loadingDate)),
                          const SizedBox(height: 6),
                          _buildDocRow('Route:', '${register.origin} to ${register.destination}', 'Supervisor:', register.supervisor),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'CARGO MANIFEST DETAILS',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 8),

                    // Table
                    Table(
                      border: TableBorder.all(color: Colors.black26),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(1.5),
                        3: FlexColumnWidth(1.2),
                        4: FlexColumnWidth(1.5),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey.shade200),
                          children: const [
                            _TableCell('Truck No.', isHeader: true),
                            _TableCell('Driver', isHeader: true),
                            _TableCell('Layers', isHeader: true),
                            _TableCell('Cartons', isHeader: true),
                            _TableCell('Status', isHeader: true),
                          ],
                        ),
                        ...register.trucks.map((t) => TableRow(
                          children: [
                            _TableCell(t.truckNumber),
                            _TableCell(t.driverName),
                            _TableCell('${t.totalLayers}'),
                            _TableCell('${t.totalCartons}'),
                            _TableCell(t.status.displayName),
                          ],
                        )),
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey.shade100),
                          children: [
                            const _TableCell('TOTALS', isHeader: true),
                            const _TableCell(''),
                            _TableCell('${register.totalLayers}', isHeader: true),
                            _TableCell('${register.totalCartons}', isHeader: true),
                            const _TableCell(''),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (register.remarks != null && register.remarks!.isNotEmpty) ...[
                      const Text('REMARKS:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
                      Text(register.remarks!, style: const TextStyle(fontSize: 11, color: Colors.black87)),
                      const SizedBox(height: 20),
                    ],

                    // Footer
                    const Divider(color: Colors.black26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Generated by Vinayak SmartLoad • Powered by Vinayak Logistics',
                          style: TextStyle(fontSize: 9, color: Colors.black54),
                        ),
                        Text(
                          'Date: ${_formatDateTime(now)} | Page 1 of 1',
                          style: const TextStyle(fontSize: 9, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirmExport();
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Print Document'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocRow(String l1, String v1, String l2, String v2) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text(l1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black54)),
              const SizedBox(width: 4),
              Text(v1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Text(l2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black54)),
              const SizedBox(width: 4),
              Text(v2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _formatDateTime(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} $h:$m';
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;

  const _TableCell(this.text, {this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: Colors.black,
        ),
      ),
    );
  }
}
