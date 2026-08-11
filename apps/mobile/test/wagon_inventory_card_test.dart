import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/wagon/domain/entities/wagon.dart';
import 'package:mobile/features/wagon/presentation/widgets/wagon_inventory_card.dart';

void main() {
  testWidgets('inventory card highlights progress and per-item remaining stock',
      (tester) async {
    final now = DateTime(2026, 8, 11);
    final wagon = Wagon(
      id: 'wagon-1',
      wagonNumber: 'W1',
      origin: 'A',
      destination: 'B',
      loadingDate: now,
      expectedTruckCount: 1,
      completedTruckCount: 0,
      status: WagonStatus.loading,
      items: const [
        WagonItem(name: 'Item A', quantity: 50),
        WagonItem(name: 'Item B', quantity: 60),
      ],
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: WagonInventoryCard(
            wagon: wagon,
            loadedByItem: const {'Item A': 50, 'Item B': 26},
          ),
        ),
      ),
    ));

    expect(find.text('69% loaded'), findsOneWidget);
    expect(find.text('76'), findsOneWidget);
    expect(find.text('34'), findsOneWidget);
    expect(find.text('COMPLETE'), findsOneWidget);
    expect(find.text('34 LEFT'), findsOneWidget);
    expect(find.text('50 loaded of 50 cartons'), findsOneWidget);
    expect(find.text('26 loaded of 60 cartons'), findsOneWidget);
  });
}
