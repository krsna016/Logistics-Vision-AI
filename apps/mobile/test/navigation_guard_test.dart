import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/presentation/widgets/unsaved_changes_guard.dart';
import 'package:mobile/core/presentation/widgets/root_back_guard.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('gesture back asks before discarding a dirty form',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UnsavedChangesGuard(
                      hasUnsavedChanges: true,
                      isSaving: false,
                      child: Scaffold(body: Text('Dirty form')),
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Discard changes?'), findsOneWidget);
    expect(find.text('Dirty form'), findsOneWidget);

    await tester.tap(find.text('Continue Editing'));
    await tester.pumpAndSettle();
    expect(find.text('Dirty form'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard Changes'));
    await tester.pumpAndSettle();
    expect(find.text('Dirty form'), findsNothing);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('back is blocked while a save is running', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: UnsavedChangesGuard(
          hasUnsavedChanges: true,
          isSaving: true,
          child: Scaffold(body: Text('Saving form')),
        ),
      ),
    );

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.text('Saving form'), findsOneWidget);
    expect(find.text('Please wait while changes are saved.'), findsOneWidget);
    expect(find.text('Discard changes?'), findsNothing);
  });

  testWidgets('standalone route gesture back uses its in-app fallback',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/truck',
      routes: [
        GoRoute(
          path: '/wagons',
          builder: (_, __) => const Scaffold(body: Text('Home page')),
        ),
        GoRoute(
          path: '/truck',
          builder: (_, __) => const Scaffold(body: Text('Standalone truck')),
        ),
      ],
    );
    addTearDown(router.dispose);
    final messengerKey = GlobalKey<ScaffoldMessengerState>();
    final dispatcher = SmartLoadBackButtonDispatcher(
      router: router,
      scaffoldMessengerKey: messengerKey,
    );

    await tester.pumpWidget(
      MaterialApp.router(
        scaffoldMessengerKey: messengerKey,
        backButtonDispatcher: dispatcher,
        routeInformationProvider: router.routeInformationProvider,
        routeInformationParser: router.routeInformationParser,
        routerDelegate: router.routerDelegate,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Standalone truck'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Standalone truck'), findsNothing);
    expect(find.text('Home page'), findsOneWidget);
  });

  testWidgets('home requires confirmation before exit', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DoubleBackToExitGuard(
          child: Scaffold(body: Text('Wagon home')),
        ),
      ),
    );

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.text('Wagon home'), findsOneWidget);
    expect(find.text('Press back again to exit the app.'), findsOneWidget);
  });
}
