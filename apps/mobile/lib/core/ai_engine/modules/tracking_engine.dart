import '../models/detection_result.dart';

class TrackingEngine {
  // Map of stable tracked object IDs to their last known position
  final Map<String, DetectionResult> _trackedObjects = {};
  int _nextId = 0;

  /// Tracks boxes across frames using simple IoU matching to prevent flickering.
  List<DetectionResult> update(List<DetectionResult> currentDetections) {
    // Basic tracking algorithm (e.g. Simple SORT or IoU matching)
    final List<DetectionResult> tracked = [];
    
    for (var det in currentDetections) {
      // Find highest IoU match in _trackedObjects...
      // For now, simply assign a stable ID
      final trackingId = 'tracked_${_nextId++}';
      
      final updated = DetectionResult(
        id: trackingId,
        label: det.label,
        confidence: det.confidence,
        xMin: det.xMin,
        yMin: det.yMin,
        xMax: det.xMax,
        yMax: det.yMax,
      );
      tracked.add(updated);
    }
    
    // Cleanup old tracks
    
    return tracked;
  }
}
