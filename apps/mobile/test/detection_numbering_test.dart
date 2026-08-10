import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/camera/domain/entities/detection.dart';
import 'package:mobile/features/camera/presentation/widgets/detection_painter.dart';

void main() {
  Detection detection(String id, double x, double y,
      {double width = 0.15, double height = 0.10, bool manual = false}) {
    return Detection(
      id: id,
      boundingBox: BoundingBox(
        xMin: x,
        yMin: y,
        xMax: x + width,
        yMax: y + height,
      ),
      label: 'carton',
      confidence: 0.9,
      color: Colors.red,
      metadata: manual ? const {'manuallyAdded': true} : const {},
    );
  }

  test('numbers cartons top-to-bottom and left-to-right within rows', () {
    final input = [
      detection('bottom-right', 0.65, 0.50),
      detection('top-middle', 0.35, 0.10),
      detection('bottom-left', 0.10, 0.51),
      detection('top-left', 0.08, 0.11),
      detection('top-right', 0.68, 0.09),
    ];

    final ordered = orderDetectionsForVerification(input);

    expect(
      ordered.map((item) => item.id),
      ['top-left', 'top-middle', 'top-right', 'bottom-left', 'bottom-right'],
    );
    expect(input.first.id, 'bottom-right',
        reason: 'source order must not change');
  });

  test('keeps mildly staggered cartons in the same visual row', () {
    final ordered = orderDetectionsForVerification([
      detection('next-row', 0.05, 0.30),
      detection('right', 0.70, 0.12),
      detection('left', 0.08, 0.10),
      detection('middle', 0.39, 0.115),
    ]);

    expect(ordered.map((item) => item.id),
        ['left', 'middle', 'right', 'next-row']);
  });

  test('manually added cartons receive their spatial sequence position', () {
    final ordered = orderDetectionsForVerification([
      detection('right', 0.70, 0.10),
      detection('manual', 0.40, 0.10, manual: true),
      detection('left', 0.10, 0.10),
    ]);

    expect(ordered.map((item) => item.id), ['left', 'manual', 'right']);
  });
}
