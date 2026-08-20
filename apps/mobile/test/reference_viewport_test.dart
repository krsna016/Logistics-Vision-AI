import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/presentation/layout/reference_viewport.dart';

void main() {
  test('reference viewport keeps its documented workspace limits', () {
    expect(SmartLoadReferenceViewport.maximumWorkspaceWidth, 520);
    expect(SmartLoadReferenceViewport.tabletShortestSide, 600);
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

    expect(normalized.size.width, closeTo(390, 0.000001));
    expect(normalized.size.height, closeTo(844, 0.000001));
    expect(normalized.padding.top, closeTo(24, 0.000001));
    expect(normalized.viewPadding.top, closeTo(24, 0.000001));
    expect(normalized.viewInsets.bottom, closeTo(300, 0.000001));
    expect(normalized.systemGestureInsets.left, closeTo(12, 0.000001));
    expect(normalized.textScaler.scale(1), closeTo(1, 0.000001));
    expect(tester.takeException(), isNull);
  });

  testWidgets('large screens use a centered phone-width workspace',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1280));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    late MediaQueryData normalized;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(800, 1280),
            devicePixelRatio: 2,
            padding: EdgeInsets.only(top: 24, left: 18, right: 18),
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
      ),
    );

    expect(normalized.size, const Size(520, 1280));
    expect(normalized.padding.left, 18);
    expect(normalized.padding.right, 18);
    expect(normalized.padding.top, 24);
    expect(tester.takeException(), isNull);
  });

  testWidgets('representative phone density matrix remains exception-free',
      (tester) async {
    const devices = <(Size, double)>[
      (Size(320, 700), 2.0),
      (Size(360, 800), 2.4),
      (Size(390, 844), 3.0),
      (Size(430, 932), 3.5),
      (Size(412, 915), 4.0),
    ];

    for (final device in devices) {
      late MediaQueryData normalized;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: device.$1,
            devicePixelRatio: device.$2,
            padding: const EdgeInsets.only(top: 28, bottom: 20),
            textScaler: const TextScaler.linear(1.3),
          ),
          child: SmartLoadReferenceViewport(
            child: Builder(
              builder: (context) {
                normalized = MediaQuery.of(context);
                return const Directionality(
                  textDirection: TextDirection.ltr,
                  child: ColoredBox(color: Colors.black),
                );
              },
            ),
          ),
        ),
      );
      expect(normalized.size.width, greaterThanOrEqualTo(320));
      expect(normalized.textScaler.scale(1), inInclusiveRange(0.92, 1.03));
      expect(tester.takeException(), isNull);
    }
  });
}
