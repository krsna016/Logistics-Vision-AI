import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/wagon/domain/entities/wagon.dart';
import 'package:mobile/features/wagon/presentation/widgets/wagon_card.dart';

void main() {
  testWidgets('wagon card keeps loaded cartons when manifest is unavailable',
      (tester) async {
    final now = DateTime(2026, 8, 12);
    final wagon = Wagon(
      id: 'wagon-1',
      wagonNumber: 'BCNHL-001',
      origin: 'Delhi',
      destination: 'Jaipur',
      loadingDate: now,
      expectedTruckCount: 0,
      completedTruckCount: 0,
      status: WagonStatus.loading,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: WagonCard(
          wagon: wagon,
          totalCartons: null,
          loadedCartons: 33,
          remainingCartons: null,
          truckCount: 1,
          onTap: () {},
        ),
      ),
    ));

    expect(find.text('33'), findsOneWidget);
    expect(find.text('--'), findsNWidgets(2));
    expect(find.text('-33'), findsNothing);
  });
}
