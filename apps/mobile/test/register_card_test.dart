import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/register/domain/entities/digital_register.dart';
import 'package:mobile/features/register/presentation/widgets/register_card.dart';
import 'package:mobile/features/wagon/domain/entities/wagon.dart';

void main() {
  testWidgets('register card shows wagon inventory balance metrics',
      (tester) async {
    final now = DateTime(2026, 8, 11);
    final register = DigitalRegister(
      id: 'register-1',
      wagonId: 'wagon-1',
      wagonNumber: 'BCNHL-001',
      origin: 'Delhi',
      destination: 'Jaipur',
      loadingDate: now,
      status: WagonStatus.loading,
      totalTrucks: 3,
      totalLayers: 8,
      totalCartons: 76,
      totalDefects: 4,
      loadingDuration: const Duration(hours: 2),
      generatedAt: now,
      lastOpenedAt: now,
      trucks: const [],
      itemBalances: const [
        RegisterItemBalance(itemName: 'A', manifest: 50, loaded: 40),
        RegisterItemBalance(itemName: 'B', manifest: 60, loaded: 36),
      ],
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RegisterCard(register: register, onTap: () {}),
      ),
    ));

    expect(find.text('TRUCKS'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('TOTAL'), findsOneWidget);
    expect(find.text('110'), findsOneWidget);
    expect(find.text('LOADED'), findsOneWidget);
    expect(find.text('76'), findsOneWidget);
    expect(find.text('REMAINING'), findsOneWidget);
    expect(find.text('34'), findsOneWidget);
    expect(find.text('LAYERS'), findsNothing);
    expect(find.text('DEFECTS'), findsNothing);
  });

  testWidgets('register card does not calculate remaining without a manifest',
      (tester) async {
    final now = DateTime(2026, 8, 12);
    final register = DigitalRegister(
      id: 'register-2',
      wagonId: 'wagon-2',
      wagonNumber: 'BCNHL-002',
      origin: 'Delhi',
      destination: 'Jaipur',
      loadingDate: now,
      status: WagonStatus.loading,
      totalTrucks: 1,
      totalLayers: 1,
      totalCartons: 33,
      totalDefects: 0,
      loadingDuration: const Duration(minutes: 30),
      generatedAt: now,
      lastOpenedAt: now,
      trucks: const [],
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RegisterCard(register: register, onTap: () {}),
      ),
    ));

    expect(find.text('33'), findsOneWidget);
    expect(find.text('--'), findsNWidgets(2));
    expect(find.text('-33'), findsNothing);
  });
}
