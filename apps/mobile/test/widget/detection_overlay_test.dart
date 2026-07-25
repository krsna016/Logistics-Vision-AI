import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/features/camera/domain/entities/detection.dart';
import 'package:mobile/features/camera/presentation/widgets/detection_overlay_widget.dart';

void main() {
  group('DetectionOverlayWidget Tests', () {
    testWidgets('Tapping overlay matches bounding box coordinate and triggers callback', (WidgetTester tester) async {
      Detection? tappedDetection;

      final mockDetections = [
        const Detection(
          id: 'det_tap_target',
          boundingBox: BoundingBox(xMin: 0.1, yMin: 0.1, xMax: 0.5, yMax: 0.5),
          label: 'target_carton',
          confidence: 0.95,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: DetectionOverlayWidget(
                detections: mockDetections,
                cameraSize: const Size(400, 400),
                fit: BoxFit.fill,
                onDetectionTapped: (det) {
                  tappedDetection = det;
                },
              ),
            ),
          ),
        ),
      );

      // Tap inside the box bounding region: center at (120, 120) which sits inside xMin/yMin bounds (40-200)
      await tester.tapAt(const Offset(120, 120));
      await tester.pump();

      expect(tappedDetection, isNotNull);
      expect(tappedDetection!.id, equals('det_tap_target'));
    });
  });
}
