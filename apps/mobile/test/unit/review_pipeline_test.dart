import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/features/layer/domain/entities/layer.dart';
import 'package:mobile/features/layer/domain/entities/ai_result.dart';
import 'package:mobile/features/layer/data/repositories_impl/local_layer_repository.dart';
import 'package:mobile/features/layer/presentation/providers/layer_providers.dart';
import 'package:mobile/features/truck/presentation/providers/truck_providers.dart';
import 'package:mobile/features/truck/data/repositories_impl/local_truck_repository.dart';

// Test double for testing repository failure rollbacks
class FailureLayerRepository extends LocalLayerRepository {
  bool shouldThrow = false;

  @override
  Future<void> saveLayer(LayerRecord layer) async {
    if (shouldThrow) {
      throw Exception('Simulated database write error');
    }
    await super.saveLayer(layer);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AIResult Entity Integrity Tests', () {
    test('Verify correct constructor instantiation', () {
      final now = DateTime.now();
      final result = AIResult(
        detections: const [],
        count: 12,
        averageConfidence: 0.94,
        processingTimeMs: 15.2,
        modelVersion: '1.0.0-YOLOv8n',
        inferenceTimestamp: now,
        frameSize: const Size(640, 640),
      );

      expect(result.count, equals(12));
      expect(result.averageConfidence, equals(0.94));
      expect(result.warnings, isEmpty);
    });
  });

  group('Transactional Save Pipeline & Rollback Tests', () {
    late FailureLayerRepository mockLayerRepo;
    late LocalTruckRepository mockTruckRepo;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockLayerRepo = FailureLayerRepository();
      mockTruckRepo = LocalTruckRepository();
    });

    ProviderContainer makeContainer() {
      final container = ProviderContainer(
        overrides: [
          layerRepositoryProvider.overrideWithValue(mockLayerRepo),
          truckRepositoryProvider.overrideWithValue(mockTruckRepo),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('Rollback prevents updating parent truck stats if layer save fails', () async {
      final container = makeContainer();

      // Retrieve initial stats for mock truck mock_t1
      final initialTruck = await mockTruckRepo.getTruckById('mock_t1');
      expect(initialTruck!.totalLayers, equals(3));
      expect(initialTruck.totalCartons, equals(72));

      // Enable simulated repository error
      mockLayerRepo.shouldThrow = true;

      // Trigger initial layers load
      await container.read(layerListProvider('mock_t1').notifier).refresh();

      // Execute save pipeline (which should throw)
      final error = await container.read(layerListProvider('mock_t1').notifier).saveLayer(
            cartonCount: 24,
            confidence: 0.95,
            notes: 'Failing save',
          );

      expect(error, contains('Failed to save layer'));

      // Verify that parent truck stats were NOT updated (Transaction Rollback)
      final rolledBackTruck = await mockTruckRepo.getTruckById('mock_t1');
      expect(rolledBackTruck!.totalLayers, equals(3)); // Stays 3, not 4
      expect(rolledBackTruck.totalCartons, equals(72)); // Stays 72, not 96
    });
  });
}
