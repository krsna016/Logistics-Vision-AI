import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/decision_state.dart';

class AIStatusCard extends StatelessWidget {
  final bool isModelLoaded;
  final double inferenceTimeMs;
  final double confidence;
  final double stabilityScore;
  final CountingDecisionState aiStatus;

  const AIStatusCard({
    super.key,
    required this.isModelLoaded,
    this.inferenceTimeMs = 0,
    this.confidence = 0,
    this.stabilityScore = 0,
    required this.aiStatus,
  });

  String _statusLabel(CountingDecisionState s) {
    // Handling possible statuses based on user requirements.
    // If CountingDecisionState is an enum, we use toString or switch.
    // Assuming standard naming convention from the prompt.
    if (s.toString().contains('collecting')) return 'Collecting';
    if (s.toString().contains('analyzing')) return 'Analyzing';
    if (s.toString().contains('stable') || s.toString().contains('readyForReview')) return 'Ready';
    if (s.toString().contains('unstable')) return 'Unstable';
    if (s.toString().contains('rejected') || s.toString().contains('error')) return 'Error';
    return 'Unknown';
  }

  Widget _Stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xCC0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isModelLoaded ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 6),
              const Text('AI ENGINE', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
              const Spacer(),
              const Text('YOLO11s v1', style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 12, color: Color(0xFF2A3F52)),
          Row(
            children: [
              Expanded(child: _Stat('Inference', '${inferenceTimeMs.toInt()} ms')),
              Expanded(child: _Stat('Confidence', '${(confidence * 100).toInt()}%')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _Stat('Stability', '${(stabilityScore * 100).toInt()}%')),
              Expanded(child: _Stat('Status', _statusLabel(aiStatus))),
            ],
          ),
        ],
      ),
    );
  }
}
