import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart' hide Detection;
import 'package:mobile/features/layer/data/repositories_impl/local_layer_repository.dart';
import 'package:mobile/features/layer/domain/entities/layer.dart';
import 'package:mobile/features/camera/domain/entities/detection.dart';
import 'package:mobile/features/truck/data/repositories_impl/local_truck_repository.dart';
import 'package:mobile/features/wagon/data/repositories_impl/local_wagon_repository.dart';
import 'package:mobile/features/register/data/repositories_impl/local_register_repository.dart';
import 'package:mobile/features/session/data/repositories_impl/local_loading_session_repository.dart';
import 'package:mobile/features/session/domain/entities/loading_session.dart'
    as domain;

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

  test('saving a layer atomically repairs truck and session aggregates',
      () async {
    await seedWagonTruck();
    final now = DateTime(2026, 8, 13, 10);

    await LocalLayerRepository(database).saveLayer(LayerRecord(
      id: 'layer-3',
      truckId: 'truck-1',
      layerNumber: 3,
      cartonCount: 5,
      defectCount: 1,
      timestamp: now,
      operatorId: 'operator-1',
      modelVersion: 'test-model',
      averageConfidence: 0.9,
      createdAt: now,
      updatedAt: now,
      detections: const [
        Detection(
          id: 'saved-mask-1',
          boundingBox: BoundingBox(
            xMin: 0.1,
            yMin: 0.2,
            xMax: 0.4,
            yMax: 0.6,
          ),
          label: 'carton',
          confidence: 0.95,
          polygon: [
            [0.1, 0.2],
            [0.4, 0.2],
            [0.4, 0.6],
            [0.1, 0.6],
          ],
        ),
      ],
    ));

    final truck = await database.select(database.trucks).getSingle();
    final session = await database.select(database.loadingSessions).getSingle();
    final queued = await database.select(database.syncQueues).get();
    expect((truck.totalLayers, truck.totalCartons, truck.totalDefects),
        (3, 35, 4));
    expect((session.totalLayers, session.totalCartons, session.totalDefects),
        (3, 35, 4));
    expect(session.averageConfidence, closeTo((0.8 + 0.6 + 0.9) / 3, 0.0001));
    expect(queued.map((item) => item.entityType).toSet(),
        containsAll(<String>{'Layer', 'Truck', 'LoadingSession'}));
    final savedLayer =
        (await LocalLayerRepository(database).getLayersByTruck('truck-1'))
            .firstWhere((layer) => layer.id == 'layer-3');
    expect(savedLayer.detections, hasLength(1));
    expect(savedLayer.detections.single.polygon, hasLength(4));
    expect(savedLayer.detections.single.polygon.first, [0.1, 0.2]);
  });

  test('database rejects two active layers with the same truck number',
      () async {
    await seedWagonTruck();

    expect(
      () => database.into(database.layers).insert(LayersCompanion.insert(
            id: 'duplicate-layer',
            truckId: 'truck-1',
            layerNumber: 2,
            cartonCount: 20,
          )),
      throwsA(isA<Exception>()),
    );
  });

  test('paused session is recovered and a second resumable session is rejected',
      () async {
    await seedWagonTruck();
    await (database.update(database.loadingSessions)
          ..where((row) => row.id.equals('session-1')))
        .write(const LoadingSessionsCompanion(status: Value('paused')));

    final recovered = await LocalLoadingSessionRepository(database)
        .getActiveSessionForTruck('truck-1');
    expect(recovered?.id, 'session-1');
    expect(recovered?.status.name, 'paused');
    expect(
      () => database.into(database.loadingSessions).insert(
            LoadingSessionsCompanion.insert(
              id: 'session-duplicate',
              truckId: 'truck-1',
              startTime: DateTime(2026, 8, 13),
              operatorId: 'operator-2',
              status: 'started',
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });

  test('session accepts an unconfigured truck warehouse without violating FK',
      () async {
    await seedWagonTruck();

    await LocalLoadingSessionRepository(database).saveSession(
      domain.LoadingSession(
        id: 'session-with-display-warehouse',
        truckId: 'truck-1',
        warehouseId: 'NIL',
        operatorId: 'operator-1',
        startTime: DateTime(2026, 8, 13),
        status: domain.SessionStatus.started,
        modelVersion: 'test-model',
      ),
    );

    final saved = await (database.select(database.loadingSessions)
          ..where((row) => row.id.equals('session-with-display-warehouse')))
        .getSingle();
    expect(saved.warehouseId, null);
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
    final deletes = await (database.select(database.syncQueues)
          ..where((row) => row.operation.equals('DELETE')))
        .get();
    expect(deletes.map((row) => row.entityType).toSet(),
        containsAll(<String>{'Truck', 'Layer', 'LoadingSession'}));
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
    final deletes = await (database.select(database.syncQueues)
          ..where((row) => row.operation.equals('DELETE')))
        .get();
    expect(deletes.map((row) => row.entityType).toSet(),
        containsAll(<String>{'Wagon', 'Truck', 'Layer', 'LoadingSession'}));
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
        cartonCount: 99,
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
    expect(
      (await database.select(database.layers).get())
          .firstWhere((record) => record.id == 'layer-1')
          .cartonCount,
      10,
    );
  });

  test('adding a missed layer photo is saved as an audited correction',
      () async {
    await seedWagonTruck();
    final repository = LocalLayerRepository(database);
    final layer = (await repository.getLayersByTruck('truck-1')).first;

    await repository.updateLayer(
      layer.copyWith(photoPath: '/temporary/new-layer-photo.jpg'),
      correctionReason: 'Photo was missed during capture',
    );

    final stored = (await database.select(database.layers).get())
        .firstWhere((record) => record.id == layer.id);
    final audit = (await database.select(database.auditLogs).get()).single;
    expect(stored.photoPath, '/temporary/new-layer-photo.jpg');
    expect(audit.action, 'correct');
    expect(audit.details, contains('Photo added'));
    expect(audit.details, contains('Photo was missed during capture'));
  });

  test('verified boxes update only the selected layer and are audited',
      () async {
    await seedWagonTruck();
    final repository = LocalLayerRepository(database);
    final layers = await repository.getLayersByTruck('truck-1');
    final selected = layers.firstWhere((layer) => layer.id == 'layer-1');
    const verified = [
      Detection(
        id: 'verified-1',
        boundingBox: BoundingBox(xMin: 0.1, yMin: 0.1, xMax: 0.3, yMax: 0.3),
        label: 'carton',
        confidence: 1,
      ),
      Detection(
        id: 'verified-2',
        boundingBox: BoundingBox(xMin: 0.4, yMin: 0.1, xMax: 0.6, yMax: 0.3),
        label: 'carton',
        confidence: 1,
      ),
    ];

    await repository.updateLayer(
      selected.copyWith(
        cartonCount: verified.length,
        detections: verified,
        itemAllocations: const [
          LayerItemAllocation(itemName: 'Item A', quantity: 1),
          LayerItemAllocation(itemName: 'Item B', quantity: 1),
        ],
      ),
      correctionReason: 'Verified boxes updated from Layer History',
    );

    final stored = await repository.getLayersByTruck('truck-1');
    final updated = stored.firstWhere((layer) => layer.id == 'layer-1');
    final untouched = stored.firstWhere((layer) => layer.id == 'layer-2');
    expect(updated.cartonCount, 2);
    expect(updated.detections.map((item) => item.id),
        ['verified-1', 'verified-2']);
    expect(untouched.cartonCount, 20);
    expect(untouched.detections, isEmpty);
    final audits = await database.select(database.auditLogs).get();
    expect(audits.single.entityId, 'layer-1');
    expect(audits.single.details, contains('Verified carton boxes updated'));
  });

  test('enterprise demo data is balanced and covers operational edge cases',
      () async {
    final wagonRepository = LocalWagonRepository(database);
    final truckRepository = LocalTruckRepository(database);
    final layerRepository = LocalLayerRepository(database);

    const operator = 'Signed-in Supervisor';
    await wagonRepository.loadDemoData(operatorName: operator);
    await truckRepository.loadDemoData(operatorName: operator);
    await layerRepository.loadDemoData(operatorName: operator);

    final visibleWagons = await wagonRepository.getActiveWagons();
    final visibleTrucks = await truckRepository.getActiveTrucks();
    final activeInventory =
        await wagonRepository.getLoadedItemQuantities('demo_wagon_active');
    final completedInventory =
        await wagonRepository.getLoadedItemQuantities('demo_wagon_completed');

    expect(visibleWagons, hasLength(5));
    expect(visibleTrucks, hasLength(10));
    expect(activeInventory, {
      'Premium Rice': 80,
      'Assam Tea': 50,
      'Whole Spices': 30,
    });
    expect(completedInventory, {
      'Consumer Electronics': 140,
      'Home Appliances': 100,
    });
    expect(
      await wagonRepository.getLoadedItemQuantities('demo_wagon_enterprise'),
      {
        'Packaged Foods': 1420,
        'Personal Care': 1430,
        'Household Goods': 1350,
      },
    );
    final enterpriseTrucks = visibleTrucks
        .where((truck) => truck.wagonId == 'demo_wagon_enterprise')
        .toList();
    expect(enterpriseTrucks, hasLength(6));
    expect(enterpriseTrucks.map((truck) => truck.totalLayers),
        containsAll([15, 16, 17, 18, 19, 20]));
    expect(
      (await database.select(database.layers).get())
          .where((layer) => !layer.isDeleted)
          .every((layer) => layer.operatorId == operator),
      isTrue,
    );
    expect(
      (await database.select(database.auditLogs).get())
          .every((audit) => audit.userId == operator),
      isTrue,
    );
    expect(await database.select(database.auditLogs).get(), hasLength(5));
    expect(await database.select(database.loadingSessions).get(), hasLength(1));
    expect(
        await database.select(database.digitalRegisters).get(), hasLength(1));
    expect(
      (await database.select(database.layers).get())
          .where((layer) => layer.isDeleted),
      hasLength(1),
    );

    final register = await LocalRegisterRepository(
      wagonRepo: wagonRepository,
      truckRepo: truckRepository,
      layerRepo: layerRepository,
      supervisorName: operator,
    ).getRegisterByWagonId('demo_wagon_enterprise');
    expect(register != null, isTrue);
    expect(register!.trucks, hasLength(6));
    expect(register.layersByTruck.values.expand((layers) => layers),
        hasLength(105));
    expect(register.manifestCartons, 4800);
    expect(register.totalCartons, 4200);
    expect(register.remainingCartons, 600);
    expect(register.isReconciled, isTrue);
  });

  test('digital register duration is measured rather than estimated', () async {
    await seedWagonTruck();
    final startedAt = DateTime(2026, 8, 12, 9);
    final finishedAt = startedAt.add(const Duration(minutes: 3));
    await (database.update(database.trucks)
          ..where((truck) => truck.id.equals('truck-1')))
        .write(TrucksCompanion(
      createdAt: Value(startedAt),
      updatedAt: Value(finishedAt),
    ));

    final register = await LocalRegisterRepository(
      wagonRepo: LocalWagonRepository(database),
      truckRepo: LocalTruckRepository(database),
      layerRepo: LocalLayerRepository(database),
    ).getRegisterByWagonId('wagon-1');

    expect(register, isNot(equals(null)));
    expect(register!.loadingDuration, const Duration(minutes: 3));
  });
}
