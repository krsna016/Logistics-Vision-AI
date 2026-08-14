import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/camera/domain/entities/detection.dart';
import 'package:mobile/features/camera/presentation/widgets/detection_overlay_widget.dart';
import 'package:mobile/features/layer/domain/entities/layer.dart';
import 'package:mobile/features/truck/presentation/widgets/layer_timeline.dart';

void main() {
  final testPng = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  );

  testWidgets('history photo keeps layer context and toggles saved masks',
      (tester) async {
    final directory = Directory.systemTemp.createTempSync('layer-viewer-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final photo = File('${directory.path}/layer.png');
    photo.writeAsBytesSync(testPng);
    final now = DateTime(2026, 8, 14, 10, 30);
    final layer = LayerRecord(
      id: 'layer-7',
      truckId: 'truck-1',
      layerNumber: 7,
      cartonCount: 42,
      timestamp: now,
      operatorId: 'Operator',
      photoPath: photo.path,
      modelVersion: 'test-model',
      averageConfidence: 0.9,
      createdAt: now,
      updatedAt: now,
      detections: const [
        Detection(
          id: 'carton-1',
          boundingBox: BoundingBox(
            xMin: 0.1,
            yMin: 0.1,
            xMax: 0.5,
            yMax: 0.6,
          ),
          label: 'carton',
          confidence: 0.9,
          polygon: [
            [0.1, 0.1],
            [0.5, 0.1],
            [0.5, 0.6],
            [0.1, 0.6],
          ],
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LayerHistoryPhotoViewer(
          layer: layer,
          file: photo,
          canEdit: false,
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const ValueKey('layer-photo-summary')), findsOneWidget);
    expect(find.text('L7'), findsOneWidget);
    expect(find.text('42 cartons'), findsOneWidget);
    expect(find.byKey(const ValueKey('layer-mask-overlay')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('layer-number-toggle')));
    await tester.pump();

    expect(find.byKey(const ValueKey('layer-mask-overlay')), findsOneWidget);
    var overlay = tester.widget<DetectionOverlayWidget>(
      find.byKey(const ValueKey('layer-mask-overlay')),
    );
    expect(overlay.showNumbers, isTrue);
    expect(overlay.showOutlines, isFalse);

    await tester.tap(find.byKey(const ValueKey('layer-mask-toggle')));
    await tester.pump();
    overlay = tester.widget<DetectionOverlayWidget>(
      find.byKey(const ValueKey('layer-mask-overlay')),
    );
    expect(overlay.showNumbers, isTrue);
    expect(overlay.showOutlines, isTrue);

    expect(
      tester.getSize(find.byKey(const ValueKey('layer-photo-summary'))).height,
      lessThan(50),
    );
  });

  testWidgets('history taps add and remove boxes and auto-save to its layer',
      (tester) async {
    final directory = Directory.systemTemp.createTempSync('layer-editor-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final photo = File('${directory.path}/layer.png');
    photo.writeAsBytesSync(testPng);
    final now = DateTime(2026, 8, 14, 10, 30);
    final layer = LayerRecord(
      id: 'layer-correct-id',
      truckId: 'truck-1',
      layerNumber: 3,
      cartonCount: 1,
      timestamp: now,
      operatorId: 'Operator',
      photoPath: photo.path,
      modelVersion: 'test-model',
      averageConfidence: 0.9,
      createdAt: now,
      updatedAt: now,
      detections: const [
        Detection(
          id: 'original-carton',
          boundingBox: BoundingBox(
            xMin: 0.1,
            yMin: 0.1,
            xMax: 0.3,
            yMax: 0.3,
          ),
          label: 'carton',
          confidence: 0.9,
        ),
      ],
    );
    final saved = <List<Detection>>[];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LayerHistoryPhotoViewer(
          layer: layer,
          file: photo,
          canEdit: true,
          onSaveDetections: (savedLayer, detections) async {
            expect(savedLayer.id, 'layer-correct-id');
            saved.add(List<Detection>.of(detections));
            return null;
          },
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('View'), findsNothing);
    expect(find.text('Add'), findsNothing);
    expect(find.text('Remove'), findsNothing);
    expect(find.text('Save'), findsNothing);
    final overlayFinder = find.byKey(const ValueKey('layer-mask-overlay'));
    final overlayBox = tester.renderObject<RenderBox>(overlayFinder);
    final size = overlayBox.size;
    final scale = size.width < size.height ? size.width : size.height;
    final dx = (size.width - scale) / 2;
    final dy = (size.height - scale) / 2;
    final addPoint = overlayBox.localToGlobal(Offset(
      dx + 0.7 * scale,
      dy + 0.5 * scale,
    ));
    await tester.tapAt(addPoint);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('2 cartons'), findsOneWidget);
    expect(saved, hasLength(1));
    expect(saved.single, hasLength(2));

    final currentOverlay = tester.widget<DetectionOverlayWidget>(overlayFinder);
    final cameraSize = currentOverlay.cameraSize;
    final removeScale =
        (size.width / cameraSize.width) < (size.height / cameraSize.height)
            ? size.width / cameraSize.width
            : size.height / cameraSize.height;
    final removeDx = (size.width - cameraSize.width * removeScale) / 2;
    final removeDy = (size.height - cameraSize.height * removeScale) / 2;
    final originalCenter = overlayBox.localToGlobal(Offset(
      removeDx + 0.2 * cameraSize.width * removeScale,
      removeDy + 0.2 * cameraSize.height * removeScale,
    ));
    await tester.tapAt(originalCenter);
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('1 cartons'), findsOneWidget);
    expect(saved, hasLength(2));
    expect(saved.last, hasLength(1));
    expect(saved.last.single.id, startsWith('history_manual_'));

    // The same tap location is now empty, so it must add a new carton again.
    await tester.tapAt(originalCenter);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('2 cartons'), findsOneWidget);
    expect(saved, hasLength(3));
    expect(saved.last, hasLength(2));
  });
}
