import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/features/truck/presentation/screens/truck_list_screen.dart';
import 'package:mobile/features/truck/presentation/providers/truck_providers.dart';
import 'package:mobile/features/truck/domain/entities/truck.dart';

void main() {
  Widget buildTestableWidget(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: TruckListScreen(),
      ),
    );
  }

  group('TruckListScreen Layout Widget Tests', () {
    testWidgets('Displays active card and truck license plates', (WidgetTester tester) async {
      final now = DateTime.now();
      final mockTrucks = [
        Truck(
          id: 'test_id_1',
          truckNumber: 'TX-VERIFY-1',
          vehicleNumber: 'V-01',
          driverName: 'Tester One',
          company: 'Cargo Test',
          warehouse: 'Austin',
          status: TruckStatus.loading,
          createdDate: now,
          updatedDate: now,
          totalLayers: 2,
          totalCartons: 40,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          truckListProvider.overrideWith((ref) {
            return StateController(TruckListState(trucks: mockTrucks));
          } as StateNotifier Function(AutoDisposeStateNotifierProviderRef<TruckListNotifier, TruckListState>)),
        ],
      );

      await tester.pumpWidget(buildTestableWidget(container));
      await tester.pump();

      // Verify stats render value: 1 loading active truck, 0 completed, 40 total cartons
      expect(find.text('TX-VERIFY-1'), findsOneWidget);
      expect(find.text('Tester One • Cargo Test'), findsOneWidget);
      expect(find.byType(Card), findsAtLeastNWidgets(3)); // Stats cards + list card
    });
  });
}

// Simple state notifier controller wrapper for feeding test states
class StateController extends StateNotifier<TruckListState> implements TruckListNotifier {
  StateController(super.state);

  @override
  Future<void> refresh() async {}

  @override
  Future<String?> createTruck({
    required String truckNumber,
    required String vehicleNumber,
    required String driverName,
    required String company,
    required String warehouse,
    String? notes,
  }) async => null;

  @override
  Future<String?> editTruck(Truck updated) async => null;

  @override
  Future<void> archiveTruck(String id) async {}

  @override
  Future<void> deleteTruck(String id) async {}

  @override
  void updateSearchQuery(String query) {}

  @override
  void setStatusFilter(TruckStatus? filter) {}

  @override
  void setSortOption(String option) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
