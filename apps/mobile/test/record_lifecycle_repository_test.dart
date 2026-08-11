import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/features/layer/data/repositories_impl/local_layer_repository.dart';
import 'package:mobile/features/layer/domain/entities/layer.dart';
import 'package:mobile/features/truck/data/repositories_impl/local_truck_repository.dart';
import 'package:mobile/features/wagon/data/repositories_impl/local_wagon_repository.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.into(database.warehouses).insert(
          WarehousesCompanion.insert(
            id: 'warehouse-1',
            name: 'Warehouse',
            location: 'Test',
          ),
        );
  });

  tearDown(() => database.close());

  Future<void> seedWagonTruck({bool archivedTruck = false}) async {
    await database.into(database.wagons).insert(
          WagonsCompanion.insert(
            id: 'wagon-1',
            wagonNumber: 'BCNAHS12345678901',
            status: 'completed',
            expectedTruckCount: 1,
          ),
        );
    await database.into(database.trucks).insert(
          TrucksCompanion.insert(
            id: 'truck-1',
            wagonId: const Value('wagon-1'),
            truckNumber: 'AS01AB1234',
            vehicleNumber: 'AS01AB1234',
            driverName: 'Driver',
            company: 'Carrier',
            status: 'completed',
            totalLayers: const Value(2),
            totalCartons: const Value(30),
            totalDefects: const Value(3),
            isArchived: Value(archivedTruck),
          ),
        );
    await database.into(database.layers).insert(
          LayersCompanion.insert(
            id: 'layer-1',
            truckId: 'truck-1',
            layerNumber: 1,
            cartonCount: 10,
            itemAllocationsJson: const Value(
                '[{"itemName":"Item A","quantity":6},{"itemName":"Item B","quantity":4}]'),
            defectCount: const Value(1),
            averageConfidence: const Value(0.8),
          ),
        );
    await database.into(database.layers).insert(
          LayersCompanion.insert(
            id: 'layer-2',
            truckId: 'truck-1',
            layerNumber: 2,
            cartonCount: 20,
            itemName: const Value('Item B'),
            defectCount: const Value(2),
            averageConfidence: const Value(0.6),
          ),
        );
    await database.into(database.loadingSessions).insert(
          LoadingSessionsCompanion.insert(
            id: 'session-1',
            truckId: 'truck-1',
            warehouseId: const Value('warehouse-1'),
            startTime: DateTime(2026),
            operatorId: 'operator-1',
            status: 'completed',
            totalLayers: const Value(2),
            totalCartons: const Value(30),
            totalDefects: const Value(3),
            averageConfidence: const Value(0.7),
          ),
        );
    await database.into(database.detections).insert(
          DetectionsCompanion.insert(
            id: 'detection-1',
            layerId: 'layer-1',
            boundingBoxX: 0,
            boundingBoxY: 0,
            boundingBoxW: 1,
            boundingBoxH: 1,
            confidence: 0.9,
            label: 'carton',
          ),
        );
  }

  test('removing a layer recalculates truck and session totals', () async {
    await seedWagonTruck();

    await LocalLayerRepository(database).softDeleteLayer('layer-1');

    final truck = await (database.select(database.trucks)
          ..where((row) => row.id.equals('truck-1')))
        .getSingle();
    final session = await (database.select(database.loadingSessions)
          ..where((row) => row.id.equals('session-1')))
        .getSingle();
    final visibleLayers =
        await LocalLayerRepository(database).getLayersByTruck('truck-1');

    expect(visibleLayers.map((layer) => layer.id), ['layer-2']);
    expect((truck.totalLayers, truck.totalCartons, truck.totalDefects),
        (1, 20, 2));
    expect((session.totalLayers, session.totalCartons, session.totalDefects),
        (1, 20, 2));
    expect(session.averageConfidence, closeTo(0.6, 0.0001));
    expect((await database.select(database.detections).getSingle()).isDeleted,
        isTrue);
  });

  test('removing a truck also removes its layers and session', () async {
    await seedWagonTruck();

    await LocalTruckRepository(database).softDeleteTruck('truck-1');

    final truck = await database.select(database.trucks).getSingle();
    final layers = await database.select(database.layers).get();
    final session = await database.select(database.loadingSessions).getSingle();
    expect(truck.isDeleted, isTrue);
    expect(layers.every((layer) => layer.isDeleted), isTrue);
    expect(session.isDeleted, isTrue);
    expect(session.status, 'cancelled');
  });

  test('removing a wagon cascades through archived trucks too', () async {
    await seedWagonTruck(archivedTruck: true);

    await LocalWagonRepository(database).deleteWagon('wagon-1');

    expect(
        (await database.select(database.wagons).getSingle()).isDeleted, isTrue);
    expect(
        (await database.select(database.trucks).getSingle()).isDeleted, isTrue);
    expect(
        (await database.select(database.layers).get())
            .every((layer) => layer.isDeleted),
        isTrue);
    expect(
        (await database.select(database.loadingSessions).getSingle()).isDeleted,
        isTrue);
  });

  test('wagon inventory totals are grouped by layer item', () async {
    await seedWagonTruck();
    final repository = LocalWagonRepository(database);

    expect(await repository.getLoadedItemQuantities('wagon-1'), {
      'Item A': 6,
      'Item B': 24,
    });

    await LocalLayerRepository(database).softDeleteLayer('layer-1');
    expect(await repository.getLoadedItemQuantities('wagon-1'), {
      'Item B': 20,
    });
  });

  test('correcting a mixed layer updates item inventory totals', () async {
    await seedWagonTruck();
    final layerRepository = LocalLayerRepository(database);
    final wagonRepository = LocalWagonRepository(database);
    final layer = (await layerRepository.getLayersByTruck('truck-1')).first;

    await layerRepository.updateLayer(
      layer.copyWith(
        itemAllocations: const [
          LayerItemAllocation(itemName: 'Item A', quantity: 5),
          LayerItemAllocation(itemName: 'Item B', quantity: 5),
        ],
      ),
      correctionReason: 'Corrected mixed item quantities',
    );

    expect(await wagonRepository.getLoadedItemQuantities('wagon-1'), {
      'Item A': 5,
      'Item B': 25,
    });
  });
}
