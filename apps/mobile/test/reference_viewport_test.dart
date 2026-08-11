import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/presentation/layout/reference_viewport.dart';

void main() {
  test('reference phone remains exactly at its current scale', () {
    expect(SmartLoadReferenceViewport.scaleForDevicePixelRatio(2.4), 1);
  });

  test('default 3x Android density matches the reference composition', () {
    expect(
      SmartLoadReferenceViewport.scaleForDevicePixelRatio(3),
      closeTo(0.8, 0.000001),
    );
  });

  test('invalid and lower densities never enlarge the approved UI', () {
    expect(SmartLoadReferenceViewport.scaleForDevicePixelRatio(0), 1);
    expect(SmartLoadReferenceViewport.scaleForDevicePixelRatio(2), 1);
  });

  testWidgets(
      'viewport normalizes size, safe area, keyboard, and text together',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    late MediaQueryData normalized;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(390, 844),
          devicePixelRatio: 3,
          padding: EdgeInsets.only(top: 24),
          viewPadding: EdgeInsets.only(top: 24),
          viewInsets: EdgeInsets.only(bottom: 300),
          systemGestureInsets: EdgeInsets.only(left: 12, right: 12),
          textScaler: TextScaler.linear(1.3),
        ),
        child: SmartLoadReferenceViewport(
          child: Builder(
            builder: (context) {
              normalized = MediaQuery.of(context);
              return const ColoredBox(color: Colors.black);
            },
          ),
        ),
      ),
    );

    expect(normalized.size.width, closeTo(487.5, 0.000001));
    expect(normalized.size.height, closeTo(1055, 0.000001));
    expect(normalized.padding.top, closeTo(30, 0.000001));
    expect(normalized.viewPadding.top, closeTo(30, 0.000001));
    expect(normalized.viewInsets.bottom, closeTo(375, 0.000001));
    expect(normalized.systemGestureInsets.left, closeTo(15, 0.000001));
    expect(normalized.textScaler.scale(1), closeTo(1.03, 0.000001));
    expect(tester.takeException(), isNull);
  });
}
