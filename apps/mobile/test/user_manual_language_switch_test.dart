import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/presentation/screens/user_manual_screen.dart';

void main() {
  testWidgets('language switch rebuilds one document from the top',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: UserManualScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Markdown, skipOffstage: false), findsOneWidget);
    var document = tester.widget<Markdown>(find.byType(Markdown));
    document.controller!.jumpTo(800);
    await tester.pump();

    await tester.tap(find.text('HI'));
    await tester.pumpAndSettle();
    expect(find.byType(Markdown, skipOffstage: false), findsOneWidget);
    document = tester.widget<Markdown>(find.byType(Markdown));
    expect(document.controller!.offset, 0);

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(find.byType(Markdown, skipOffstage: false), findsOneWidget);
    document = tester.widget<Markdown>(find.byType(Markdown));
    expect(document.controller!.offset, 0);
    expect(tester.takeException(), isNull);
  });
}
