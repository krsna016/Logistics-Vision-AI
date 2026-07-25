import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/camera/domain/entities/detection.dart';
import 'package:mobile/features/camera/presentation/widgets/detection_painter.dart';

void main() {
  group('DetectionPainter Unit Tests', () {
    final mockDetections = [
      const Detection(
        id: 'det_1',
        boundingBox: BoundingBox(xMin: 0.1, yMin: 0.2, xMax: 0.5, yMax: 0.6),
        label: 'carton',
        confidence: 0.92,
      ),
    ];

    test('shouldRepaint returns false for identical arguments', () {
      final painter1 = DetectionPainter(
        detections: mockDetections,
        cameraSize: const Size(720, 1280),
        fit: BoxFit.cover,
      );

      final painter2 = DetectionPainter(
        detections: mockDetections,
        cameraSize: const Size(720, 1280),
        fit: BoxFit.cover,
      );

      expect(painter1.shouldRepaint(painter2), isFalse);
    });

    test('shouldRepaint returns true when detections modify', () {
      final painter1 = DetectionPainter(
        detections: mockDetections,
        cameraSize: const Size(720, 1280),
        fit: BoxFit.cover,
      );

      final painter2 = DetectionPainter(
        detections: const [],
        cameraSize: const Size(720, 1280),
        fit: BoxFit.cover,
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns true when camera size alters', () {
      final painter1 = DetectionPainter(
        detections: mockDetections,
        cameraSize: const Size(720, 1280),
        fit: BoxFit.cover,
      );

      final painter2 = DetectionPainter(
        detections: mockDetections,
        cameraSize: const Size(1080, 1920),
        fit: BoxFit.cover,
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });
  });
}
