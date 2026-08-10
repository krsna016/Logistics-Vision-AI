import '../models/detection_result.dart';

class TrackingEngine {
  int _nextId = 0;
  final List<_Track> _tracks = [];
  final double matchThreshold;
  final int maxMissedFrames;

  TrackingEngine({this.matchThreshold = 0.25, this.maxMissedFrames = 3});

  /// Tracks boxes across frames using simple IoU matching to prevent flickering.
  List<DetectionResult> update(List<DetectionResult> currentDetections) {
    final matchedTrackIndexes = <int>{};
    final nextTracks = <_Track>[];
    final tracked = <DetectionResult>[];

    for (final detection in currentDetections) {
      var bestIndex = -1;
      var bestIou = matchThreshold;
      for (var index = 0; index < _tracks.length; index++) {
        if (matchedTrackIndexes.contains(index)) continue;
        final iou = _iou(_tracks[index].detection, detection);
        if (iou > bestIou) {
          bestIou = iou;
          bestIndex = index;
        }
      }

      final id = bestIndex >= 0
          ? _tracks[bestIndex].detection.id
          : 'tracked_${_nextId++}';
      final updated = DetectionResult(
        id: id,
        label: detection.label,
        confidence: detection.confidence,
        xMin: detection.xMin,
        yMin: detection.yMin,
        xMax: detection.xMax,
        yMax: detection.yMax,
        // Preserve the segmentation contour while assigning the stable
        // tracking id. Dropping this here makes the painter fall back to a
        // rectangle even when the model produced a valid mask.
        polygon: detection.polygon,
      );
      tracked.add(updated);
      nextTracks.add(_Track(updated));
      if (bestIndex >= 0) matchedTrackIndexes.add(bestIndex);
    }

    for (var index = 0; index < _tracks.length; index++) {
      if (matchedTrackIndexes.contains(index)) continue;
      final previous = _tracks[index];
      if (previous.missedFrames + 1 <= maxMissedFrames) {
        nextTracks.add(_Track(
          previous.detection,
          missedFrames: previous.missedFrames + 1,
        ));
      }
    }

    _tracks
      ..clear()
      ..addAll(nextTracks);
    return tracked;
  }

  double _iou(DetectionResult first, DetectionResult second) {
    final left = first.xMin > second.xMin ? first.xMin : second.xMin;
    final top = first.yMin > second.yMin ? first.yMin : second.yMin;
    final right = first.xMax < second.xMax ? first.xMax : second.xMax;
    final bottom = first.yMax < second.yMax ? first.yMax : second.yMax;
    final intersection =
        (right - left).clamp(0.0, 1.0) * (bottom - top).clamp(0.0, 1.0);
    if (intersection <= 0) return 0;
    final firstArea = (first.xMax - first.xMin) * (first.yMax - first.yMin);
    final secondArea =
        (second.xMax - second.xMin) * (second.yMax - second.yMin);
    final union = firstArea + secondArea - intersection;
    return union <= 0 ? 0 : intersection / union;
  }

  void reset() => _tracks.clear();
}

class _Track {
  final DetectionResult detection;
  final int missedFrames;

  const _Track(this.detection, {this.missedFrames = 0});
}
