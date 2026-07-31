import 'package:flutter/material.dart';
import '../../domain/entities/inference_telemetry.dart';

class DebugTelemetryOverlay extends StatelessWidget {
  final InferenceTelemetry telemetry;

  const DebugTelemetryOverlay({
    super.key,
    required this.telemetry,
  });

  @override
  Widget build(BuildContext context) {
    final double totalLatency = telemetry.preprocessingTimeMs +
        telemetry.inferenceTimeMs +
        telemetry.postprocessingTimeMs;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTelemetryRow('Model Version', telemetry.modelVersion),
          const Divider(color: Colors.white24, height: 8),
          _buildTelemetryRow(
              'Engine FPS', '${telemetry.fps.toStringAsFixed(1)} FPS'),
          _buildTelemetryRow(
              'Detections', '${telemetry.totalDetectionsCount} boxes'),
          _buildTelemetryRow(
              'Dropped Frames', '${telemetry.droppedFramesCount} frames'),
          const Divider(color: Colors.white24, height: 8),
          _buildTelemetryRow('Prep Latency',
              '${telemetry.preprocessingTimeMs.toStringAsFixed(1)} ms'),
          _buildTelemetryRow('Model Latency',
              '${telemetry.inferenceTimeMs.toStringAsFixed(1)} ms'),
          _buildTelemetryRow('Post Latency',
              '${telemetry.postprocessingTimeMs.toStringAsFixed(1)} ms'),
          _buildTelemetryRow(
              'Total Latency', '${totalLatency.toStringAsFixed(1)} ms'),
        ],
      ),
    );
  }

  Widget _buildTelemetryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 16),
          Text(
            value,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
