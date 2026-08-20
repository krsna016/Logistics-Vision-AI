import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/layer/domain/entities/layer.dart';
import 'package:mobile/features/truck/presentation/widgets/layer_timeline.dart';

void main() {
  testWidgets('mixed-item layer wraps without overflowing a compact phone',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final timestamp = DateTime(2026, 8, 11, 5, 12);
    final layer = LayerRecord(
      id: 'layer-15',
      truckId: 'truck-1',
      layerNumber: 15,
      cartonCount: 47,
      defectCount: 2,
      timestamp: timestamp,
      operatorId: 'operator-1',
      notes: 'Mixed-item layer manually verified',
      itemAllocations: const [
        LayerItemAllocation(itemName: 'Packaged Foods', quantity: 15),
        LayerItemAllocation(itemName: 'Personal Care', quantity: 2),
        LayerItemAllocation(itemName: 'Household Goods', quantity: 30),
      ],
      modelVersion: 'manual',
      averageConfidence: 1,
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LayerTimeline(
                layers: [layer],
                isReadOnly: false,
                onEditNotes: (_) {},
                onDeleteLayer: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Packaged Foods: 15'), findsOneWidget);
    expect(find.text('Personal Care: 2'), findsOneWidget);
    expect(find.text('Household Goods: 30'), findsOneWidget);
    expect(find.text('47 Cartons'), findsOneWidget);
    expect(find.text('05:12'), findsOneWidget);
    expect(find.text('2 Defective'), findsOneWidget);
    expect(find.byIcon(Icons.edit_note_outlined), findsNothing);
    expect(find.byIcon(Icons.add_a_photo_outlined), findsNothing);
    final layerTop = tester.getTopLeft(find.text('Layer 15')).dy;
    expect(tester.getTopLeft(find.text('47 Cartons')).dy, closeTo(layerTop, 3));
    expect(tester.getTopLeft(find.text('05:12')).dy, closeTo(layerTop, 3));
    expect(
      tester.getCenter(find.byIcon(Icons.delete_outline)).dy,
      lessThanOrEqualTo(layerTop + 10),
    );
    expect(
      tester.getRect(find.byKey(const ValueKey('layer-delete-button'))).right,
      greaterThan(tester.getRect(find.text('05:12')).right),
    );
    expect(tester.getTopLeft(find.text('2 Defective')).dy, greaterThan(layerTop));
    expect(
      tester.getTopLeft(find.text('Packaged Foods: 15')).dy,
      greaterThan(layerTop),
    );
    expect(tester.takeException(), isNull);
  });
}
