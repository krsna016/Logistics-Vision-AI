import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class QualityIndicator extends StatelessWidget {
  final double qualityScore; // 0.0 to 1.0
  final List<String> warnings;

  const QualityIndicator({
    super.key,
    required this.qualityScore,
    this.warnings = const [],
  });

  @override
  Widget build(BuildContext context) {
    String label = 'POOR';
    IconData icon = Icons.warning_amber_outlined;
    Color color = Colors.red;

    if (qualityScore >= 0.8) {
      label = 'EXCELLENT';
      icon = Icons.check_circle_outline;
      color = Colors.green;
    } else if (qualityScore >= 0.5) {
      label = 'GOOD';
      icon = Icons.info_outline;
      color = Colors.orange;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        if (label == 'POOR' && warnings.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: 200,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xCC000000),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: warnings
                  .take(2)
                  .map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning,
                                color: Colors.red, size: 12),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(w,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 10)),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ]
      ],
    );
  }
}
