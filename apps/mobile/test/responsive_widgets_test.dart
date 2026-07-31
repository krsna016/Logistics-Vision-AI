import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/presentation/layout/responsive.dart';
import 'package:mobile/presentation/widgets/status_chip.dart';
import 'package:mobile/theme/app_theme.dart';

void main() {
  testWidgets('responsive content width is constrained on wide screens',
      (tester) async {
    late double contentWidth;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            contentWidth = AppResponsive.contentWidth(context, max: 400);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(contentWidth, 400);
  });

  testWidgets('status chip renders its label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: StatusChip(
            type: CustomStatusType.active,
            label: 'Loading',
          ),
        ),
      ),
    );

    expect(find.text('LOADING'), findsOneWidget);
  });
}
