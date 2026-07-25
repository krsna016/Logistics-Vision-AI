import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/features/layer/domain/entities/layer.dart';
import 'package:mobile/features/layer/data/models/layer_model.dart';
import 'package:mobile/features/layer/data/repositories_impl/local_layer_repository.dart';
import 'package:mobile/features/layer/presentation/providers/layer_providers.dart';
import 'package:mobile/features/truck/presentation/providers/truck_providers.dart';
import 'package:mobile/features/truck/data/repositories_impl/local_truck_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Layer Model Serialization Tests', () {
    test('fromJson and toJson map fields accurately without data loss', () {
      final now = DateTime.parse('2026-07-25T13:00:00Z');
      final record = LayerRecord(
        id: 'layer_uuid',
        truckId: 'truck_uuid',
        layerNumber: 4,
        cartonCount: 20,
        timestamp: now,
        operatorId: 'operator_01',
        modelVersion: '1.0.0-YOLOv8n',
        averageConfidence: 0.95,
        createdAt: now,
        updatedAt: now,
      );

      final json = LayerModel.toJson(record);
      final mappedRecord = LayerModel.fromJson(json);

      expect(mappedRecord.id, equals(record.id));
      expect(mappedRecord.layerNumber, equals(record.layerNumber));
      expect(mappedRecord.cartonCount, equals(record.cartonCount));
      expect(mappedRecord.averageConfidence, equals(record.averageConfidence));
    });
  });

  group('LocalLayerRepository Tests', () {
    late LocalLayerRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({}); // Clean cache
      repository = LocalLayerRepository();
    });

    test('getLayersByTruck returns initial mock seeds when database is empty', () async {
      final list = await repository.getLayersByTruck('mock_t1');
      expect(list.length, equals(3));
      expect(list[0].layerNumber, equals(1));
      expect(list[0].cartonCount, equals(24));
    });

    test('isLayerNumberExists returns true if layer number already registered', () async {
      await repository.getLayersByTruck('mock_t1'); // Initialize mocks
      final exists = await repository.isLayerNumberExists('mock_t1', 2);
      expect(exists, isTrue);

      final notExists = await repository.isLayerNumberExists('mock_t1', 5);
      expect(notExists, isFalse);
    });
  });

  group('LayerListNotifier State Transitions & Parent Truck Updates', () {
    late LocalLayerRepository layerRepo;
    late LocalTruckRepository truckRepo;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      layerRepo = LocalLayerRepository();
      truckRepo = LocalTruckRepository();
    });

    ProviderContainer makeContainer() {
      final container = ProviderContainer(
        overrides: [
          layerRepositoryProvider.overrideWithValue(layerRepo),
          truckRepositoryProvider.overrideWithValue(truckRepo),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('Saving a layer auto-increments layers count and updates parent truck totals', () async {
      final container = makeContainer();

      // Retrieve initial mock truck status
      final initialTruck = await truckRepo.getTruckById('mock_t1');
      expect(initialTruck!.totalLayers, equals(3));
      expect(initialTruck.totalCartons, equals(72));

      // Trigger initial layers load
      await container.read(layerListProvider('mock_t1').notifier).refresh();

      // Save new layer with 24 cartons
      final error = await container.read(layerListProvider('mock_t1').notifier).saveLayer(
            cartonCount: 24,
            confidence: 0.95,
            notes: 'Extra layer saved',
          );

      expect(error, isNull);

      // Verify layers list has increased to 4
      final processedLayers = container.read(layerListProvider('mock_t1')).layers;
      expect(processedLayers.length, equals(4));
      expect(processedLayers.last.layerNumber, equals(4));

      // Verify parent truck totals have incremented
      final updatedTruck = await truckRepo.getTruckById('mock_t1');
      expect(updatedTruck!.totalLayers, equals(4));
      expect(updatedTruck.totalCartons, equals(96)); // 72 + 24
    });
  });
}
