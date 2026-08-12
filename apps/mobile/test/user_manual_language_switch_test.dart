import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/presentation/screens/user_manual_screen.dart';

void main() {
  testWidgets('language switch rebuilds the sectioned document from the top',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: UserManualScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MarkdownBody, skipOffstage: false), findsWidgets);
    final manualList = find.byType(ListView);
    final scrollable = find.descendant(
      of: manualList,
      matching: find.byType(Scrollable),
    );
    var position = tester.state<ScrollableState>(scrollable).position;
    position.jumpTo(800);
    await tester.pump();

    await tester.tap(find.text('HI'));
    await tester.pumpAndSettle();
    expect(find.byType(MarkdownBody, skipOffstage: false), findsWidgets);
    position = tester.state<ScrollableState>(scrollable).position;
    expect(position.pixels, 0);

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(find.byType(MarkdownBody, skipOffstage: false), findsWidgets);
    position = tester.state<ScrollableState>(scrollable).position;
    expect(position.pixels, 0);
    expect(tester.takeException(), isNull);
  });
}
