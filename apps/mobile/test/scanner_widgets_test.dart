import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/truck/presentation/widgets/scanner_capture_controls.dart';
import 'package:mobile/features/truck/presentation/widgets/scanner_starting_view.dart';

void main() {
  testWidgets('scanner controls expose only the flash action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScannerCaptureControls(
            torchOn: false,
            onToggleTorch: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.flash_off_rounded), findsOneWidget);
    expect(find.byIcon(Icons.photo_library_outlined), findsNothing);
    expect(find.byIcon(Icons.camera_alt_rounded), findsNothing);
  });

  testWidgets('camera starting view shows a compact progress indicator',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ScannerStartingView())),
    );

    expect(find.text('Starting camera…'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
