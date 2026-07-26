import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/features/truck/domain/entities/truck.dart';
import 'package:mobile/features/truck/data/models/truck_model.dart';
import 'package:mobile/features/truck/data/repositories_impl/local_truck_repository.dart';
import 'package:mobile/features/truck/presentation/providers/truck_providers.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:drift/native.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Truck Model Serialization Tests', () {
    test('fromJson and toJson map fields accurately without data loss', () {
      final now = DateTime.parse('2026-07-25T12:00:00Z');
      final truck = Truck(
        id: 'test_uuid',
        truckNumber: 'CA-1122-ZZ',
        vehicleNumber: 'V-999',
        driverName: 'Robert Johnson',
        company: 'FastCargo LLC',
        warehouse: 'Austin Fulfillment South',
        status: TruckStatus.loading,
        createdDate: now,
        updatedDate: now,
        notes: 'Side panels loose',
      );

      final json = TruckModel.toJson(truck);
      final mappedTruck = TruckModel.fromJson(json);

      expect(mappedTruck.id, equals(truck.id));
      expect(mappedTruck.truckNumber, equals(truck.truckNumber));
      expect(mappedTruck.status, equals(truck.status));
      expect(mappedTruck.notes, equals('Side panels loose'));
    });
  });

  group('LocalTruckRepository Tests', () {
    late AppDatabase db;
    late LocalTruckRepository repository;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repository = LocalTruckRepository(db);
      await repository.clearAndLoadDemoData();
    });

    tearDown(() async {
      await db.close();
    });

    test('getActiveTrucks returns initial mock seeds when database is empty', () async {
      final list = await repository.getActiveTrucks();
      expect(list.length, equals(2));
      expect(list[0].truckNumber, equals('TX-9908-AB'));
    });

    test('createTruck adds new entry to local storage', () async {
      await repository.getActiveTrucks(); // Initialize
      final now = DateTime.now();
      final newTruck = Truck(
        id: 'new_uuid',
        truckNumber: 'FL-8899-CD',
        vehicleNumber: 'V-300',
        driverName: 'Sam Harris',
        company: 'Ocean Shipping',
        warehouse: 'Austin Fulfillment South',
        status: TruckStatus.loading,
        createdDate: now,
        updatedDate: now,
      );

      await repository.createTruck(newTruck);
      final activeList = await repository.getActiveTrucks();
      
      expect(activeList.length, equals(3));
      expect(activeList.any((t) => t.id == 'new_uuid'), isTrue);
    });

    test('softDeleteTruck updates isDeleted flag instead of hard purging', () async {
      await repository.getActiveTrucks(); // Initialize
      await repository.softDeleteTruck('mock_t1');
      
      final activeList = await repository.getActiveTrucks();
      expect(activeList.length, equals(1)); // mock_t1 filtered out
      expect(activeList.any((t) => t.id == 'mock_t1'), isFalse);
    });
  });

  group('TruckListNotifier State & Validation Tests', () {
    late AppDatabase db;
    late LocalTruckRepository repo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = LocalTruckRepository(db);
      await repo.clearAndLoadDemoData();
    });

    tearDown(() async {
      await db.close();
    });

    ProviderContainer makeContainer() {
      final container = ProviderContainer(
        overrides: [
          truckRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('Notifier filters trucks correctly based on search query', () async {
      final container = makeContainer();
      
      // Trigger initial mock load
      await container.read(truckListProvider.notifier).refresh();

      // Set search query 'john' (should match 'John Doe' in mock_t1)
      container.read(truckListProvider.notifier).updateSearchQuery('john');
      
      final processed = container.read(truckListProvider).processedTrucks;
      expect(processed.length, equals(1));
      expect(processed[0].driverName, equals('John Doe'));
    });

    test('Notifier rejects duplicate truck numbers', () async {
      final container = makeContainer();
      await container.read(truckListProvider.notifier).refresh();

      // Attempt to create a truck with duplicate number 'TX-9908-AB'
      final error = await container.read(truckListProvider.notifier).createTruck(
        truckNumber: 'TX-9908-AB',
        vehicleNumber: 'V-200',
        driverName: 'Mark',
        company: 'Swift',
        warehouse: 'Facility',
      );

      expect(error, contains('already exists'));
    });
  });
}
