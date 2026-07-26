import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/features/camera/presentation/screens/camera_screen.dart';
import 'package:mobile/features/camera/presentation/providers/camera_notifier.dart';
import 'package:mobile/features/camera/presentation/providers/camera_state.dart';

void main() {
  Widget buildTestableWidget(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: CameraScreen(),
      ),
    );
  }

  group('CameraScreen Layout Widget Tests', () {
    testWidgets('Displays loader during hardware initialization', (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          cameraNotifierProvider.overrideWith((ref) {
            return StateController(const CameraState(status: CameraStatus.initializing));
          }),
        ],
      );

      await tester.pumpWidget(buildTestableWidget(container));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Accessing camera hardware...'), findsOneWidget);
    });

    testWidgets('Displays error layout and retry button on connection failure', (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          cameraNotifierProvider.overrideWith((ref) {
            return StateController(const CameraState(
              status: CameraStatus.error,
              errorMessage: 'Hardware connection lost.',
            ));
          }),
        ],
      );

      await tester.pumpWidget(buildTestableWidget(container));

      expect(find.text('Camera Error Occurred'), findsOneWidget);
      expect(find.text('Hardware connection lost.'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Displays permission request buttons when access is blocked', (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          cameraNotifierProvider.overrideWith((ref) {
            return StateController(const CameraState(status: CameraStatus.permissionDenied));
          }),
        ],
      );

      await tester.pumpWidget(buildTestableWidget(container));

      expect(find.text('Camera Permission Denied'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}

// Simple state controller subclass to easily feed test states into overrides
class StateController extends StateNotifier<CameraState> implements CameraNotifier {
  StateController(super.state);

  @override
  Future<void> initialize() async {}

  @override
  Future<void> switchCamera() async {}

  @override
  Future<void> disposeCamera() async {}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
