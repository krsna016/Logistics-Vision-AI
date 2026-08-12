import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/camera/presentation/widgets/resizable_counting_region.dart';
import 'package:mobile/features/layer/domain/entities/layer.dart';

void main() {
  test('counting region serializes independent normalized corners', () {
    const region = CountingRegion(
      topLeft: CountingPoint(0.12, 0.23),
      topRight: CountingPoint(0.88, 0.18),
      bottomRight: CountingPoint(0.82, 0.79),
      bottomLeft: CountingPoint(0.18, 0.84),
    );

    expect(CountingRegion.fromJson(region.toJson()).toJson(), region.toJson());
  });

  test('counting region reads prior rectangular audit data', () {
    final region = CountingRegion.fromJson(const {
      'left': 0.12,
      'top': 0.23,
      'right': 0.88,
      'bottom': 0.79,
    });

    expect(region.topLeft.x, 0.12);
    expect(region.topRight.y, 0.23);
    expect(region.bottomRight.x, 0.88);
    expect(region.bottomLeft.y, 0.79);
  });

  testWidgets('top edge drag moves both top corners vertically',
      (tester) async {
    final initial = CountingRegion.rectangle(
      left: 0.10,
      top: 0.20,
      right: 0.90,
      bottom: 0.80,
    );
    final committed = <CountingRegion>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: ResizableCountingRegion(
              region: initial,
              onChanged: committed.add,
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(const Offset(200, 120));
    await gesture.moveTo(const Offset(200, 160));
    await gesture.up();

    expect(committed, hasLength(1));
    expect(committed.single.topLeft.y, greaterThan(initial.topLeft.y));
    expect(committed.single.topRight.y, greaterThan(initial.topRight.y));
  });
}
