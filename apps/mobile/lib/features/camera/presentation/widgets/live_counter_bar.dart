import 'package:flutter/material.dart';
import '../../domain/entities/decision_state.dart';
import '../../../../core/ai_engine/models/ai_model.dart';

class LiveCounterBar extends StatelessWidget {
  final int detectedCount;
  final double confidence;
  final int fps;
  final CountingDecisionState status;

  const LiveCounterBar({
    super.key,
    required this.detectedCount,
    this.confidence = 0,
    this.fps = 0,
    required this.status,
  });

  Color _getStatusColor() {
    final s = status.toString();
    if (s.contains('stable') || s.contains('readyForReview')) {
      return Colors.green;
    }
    if (s.contains('collecting') ||
        s.contains('analyzing') ||
        s.contains('unstable')) {
      return Colors.orange;
    }
    return Colors.red; // default or error
  }

  Color _getConfidenceColor() {
    if (confidence > 0.85) return Colors.green;
    if (confidence > 0.6) return Colors.orange;
    return Colors.red;
  }

  Widget _counterColumn(String label, String value, Color valueColor,
      {bool animate = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        if (animate)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Text(
              value,
              key: ValueKey<String>(value),
              style: TextStyle(
                  color: valueColor, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
                color: valueColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xCC0D1B2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: _getStatusColor(),
            width: 1), // Using status color for border
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _counterColumn('DETECTED', '$detectedCount', Colors.white,
                animate: true),
            Container(
                height: 30,
                width: 1,
                color: Colors.grey.withValues(alpha: 0.3),
                margin: const EdgeInsets.symmetric(horizontal: 12)),
            _counterColumn('CONFIDENCE', '${(confidence * 100).toInt()}%',
                _getConfidenceColor()),
            Container(
                height: 30,
                width: 1,
                color: Colors.grey.withValues(alpha: 0.3),
                margin: const EdgeInsets.symmetric(horizontal: 12)),
            _counterColumn('FPS', '$fps', Colors.white),
            Container(
                height: 30,
                width: 1,
                color: Colors.grey.withValues(alpha: 0.3),
                margin: const EdgeInsets.symmetric(horizontal: 12)),
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('MODEL',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text(AIModel.activeLabel,
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
