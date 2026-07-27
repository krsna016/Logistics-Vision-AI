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
    const docBlue = Color(0xFF1E3A8A); // Deep corporate blue
    const textDark = Color(0xFF1E293B);
    const textLight = Color(0xFF64748B);

    return Dialog(
      backgroundColor: AppTheme.surfaceColor, // Dark wrapper
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 800),
        child: Column(
          children: [
            // Dark Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.dividerColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.description_outlined, color: Colors.white70),
                      SizedBox(width: 12),
                      Text(
                        'PRINT PREVIEW',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 24,
                  ),
                ],
              ),
            ),
            
            // Scrollable Document Area (Grey background holding white paper)
            Expanded(
              child: Container(
                color: AppTheme.backgroundColor,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Container(
                      width: 650, // Fixed width for A4 proportion
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Watermark
                          Positioned.fill(
                            child: Center(
                              child: Transform.rotate(
                                angle: -0.5,
                                child: Icon(
                                  Icons.verified,
                                  size: 250,
                                  color: Colors.green.withValues(alpha: 0.04),
                                ),
                              ),
                            ),
                          ),
                          
                          // Document Content
                          Padding(
                            padding: const EdgeInsets.all(48), // Large margins for print
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'VINAYAK LOGISTICS',
                                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: docBlue, letterSpacing: 1.5),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            'SMARTLOAD DIGITAL MANIFEST',
                                            style: TextStyle(fontSize: 12, color: textLight, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                          ),
                                          const SizedBox(height: 16),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              border: Border.all(color: Colors.green.shade300),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text('VERIFIED & SECURED', style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Image.asset('assets/images/logo.png', height: 60, width: 60, fit: BoxFit.contain),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                // Meta Information (Modern clean layout)
                                Row(
                                  children: [
                                    Expanded(child: _buildMetaGroup('Wagon Number', register.wagonNumber, docBlue, textDark)),
                                    Expanded(child: _buildMetaGroup('Loading Date', _formatDate(register.loadingDate), docBlue, textDark)),
                                    Expanded(child: _buildMetaGroup('Supervisor', register.supervisor, docBlue, textDark)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildMetaGroup('Route Details', '${register.origin} ➔ ${register.destination}', docBlue, textDark),
                                
                                const SizedBox(height: 32),
                                const Divider(color: Color(0xFFE2E8F0), thickness: 2),
                                const SizedBox(height: 24),

                                const Text(
                                  'CARGO MANIFEST',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: docBlue, letterSpacing: 1.0),
                                ),
                                const SizedBox(height: 16),

                                // Professional Data Table
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Table(
                                    border: TableBorder.all(color: const Color(0xFFCBD5E1), width: 1),
                                    columnWidths: const {
                                      0: FlexColumnWidth(2),
                                      1: FlexColumnWidth(2.5),
                                      2: FlexColumnWidth(1.2),
                                      3: FlexColumnWidth(1.2),
                                      4: FlexColumnWidth(1.5),
                                    },
                                    children: [
                                      // Table Header
                                      TableRow(
                                        decoration: const BoxDecoration(color: docBlue),
                                        children: const [
                                          _TableCell('Truck No.', isHeader: true),
                                          _TableCell('Driver', isHeader: true),
                                          _TableCell('Layers', isHeader: true),
                                          _TableCell('Cartons', isHeader: true),
                                          _TableCell('Status', isHeader: true),
                                        ],
                                      ),
                                      // Rows
                                      ...register.trucks.asMap().entries.map((entry) {
                                        final int idx = entry.key;
                                        final Truck t = entry.value;
                                        return TableRow(
                                          decoration: BoxDecoration(color: idx.isEven ? Colors.white : const Color(0xFFF8FAFC)),
                                          children: [
                                            _TableCell(t.truckNumber),
                                            _TableCell(t.driverName),
                                            _TableCell('${t.totalLayers}', isNumeric: true),
                                            _TableCell('${t.totalCartons}', isNumeric: true),
                                            _TableCell(t.status.displayName),
                                          ],
                                        );
                                      }),
                                      // Totals Footer
                                      TableRow(
                                        decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                                        children: [
                                          const _TableCell('TOTALS', isBold: true),
                                          const _TableCell(''),
                                          _TableCell('${register.totalLayers}', isBold: true, isNumeric: true),
                                          _TableCell('${register.totalCartons}', isBold: true, isNumeric: true),
                                          const _TableCell(''),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),

                                if (register.remarks != null && register.remarks!.isNotEmpty) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      border: Border(left: BorderSide(color: Colors.amber.shade400, width: 4)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('REMARKS / NOTES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textLight)),
                                        const SizedBox(height: 4),
                                        Text(register.remarks!, style: const TextStyle(fontSize: 12, color: textDark)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                ] else ...[
                                  const SizedBox(height: 20),
                                ],

                                // Footer Signatures
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildSignatureLine('Supervisor Signature'),
                                    _buildSignatureLine('Facility Manager'),
                                  ],
                                ),
                                const SizedBox(height: 48),

                                // Document Footer text
                                const Divider(color: Color(0xFFE2E8F0)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Generated securely via Vinayak SmartLoad API', style: TextStyle(fontSize: 9, color: textLight)),
                                    Text('Printed: ${_formatDateTime(now)}', style: const TextStyle(fontSize: 9, color: textLight)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: AppTheme.surfaceColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirmExport();
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Print Document'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaGroup(String label, String value, Color labelColor, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: labelColor.withValues(alpha: 0.6))),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor)),
      ],
    );
  }

  Widget _buildSignatureLine(String label) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 150,
          height: 1,
          color: const Color(0xFF94A3B8),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} at $h:$m';
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  final bool isBold;
  final bool isNumeric;

  const _TableCell(this.text, {this.isHeader = false, this.isBold = false, this.isNumeric = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      child: Text(
        text,
        textAlign: isNumeric ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isHeader || isBold ? FontWeight.bold : FontWeight.w500,
          color: isHeader ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
    );
  }
}
