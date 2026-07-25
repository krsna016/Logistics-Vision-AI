import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/features/dataset/domain/entities/dataset_item.dart';
import 'package:mobile/features/dataset/data/models/dataset_item_model.dart';
import 'package:mobile/features/dataset/data/repositories_impl/local_dataset_repository.dart';
import 'package:mobile/features/dataset/presentation/providers/dataset_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DatasetItem Quality & Model Serialization Tests', () {
    test('Calculates accurate quality score based on sharpness and exposure range', () {
      final item = DatasetItem(
        id: 'test_id',
        timestamp: DateTime.now(),
        phoneModel: 'iPhone 15',
        cameraResolution: '1920x1080',
        orientation: 'portrait',
        brightness: 120.0,
        exposure: 128.0, // Perfect exposure (128.0 delta is 0)
        sharpness: 80.0,  // Sharpness is 80%
        warehouseId: 'wh_01',
        imagePath: '/tmp/test.jpg',
        metadataPath: '/tmp/test.json',
      );

      // Sharpness contribution: 0.8 * 0.6 = 0.48
      // Exposure contribution: (1 - 0) * 0.4 = 0.40
      // Total quality score: 0.88
      expect(item.qualityScore, closeTo(0.88, 0.01));
    });

    test('fromJson and toJson map fields accurately without data loss', () {
      final now = DateTime.parse('2026-07-25T17:00:00Z');
      final item = DatasetItem(
        id: 'uuid_123',
        timestamp: now,
        phoneModel: 'Pixel 8',
        cameraResolution: '4032x3024',
        orientation: 'landscape',
        brightness: 130.0,
        exposure: 140.0,
        sharpness: 90.0,
        warehouseId: 'wh_south',
        truckId: 'truck_99',
        notes: 'Low angle shot',
        imagePath: '/tmp/uuid_123.jpg',
        metadataPath: '/tmp/uuid_123.json',
      );

      final json = DatasetItemModel.toJson(item);
      final mappedItem = DatasetItemModel.fromJson(json);

      expect(mappedItem.id, equals(item.id));
      expect(mappedItem.phoneModel, equals(item.phoneModel));
      expect(mappedItem.qualityScore, equals(item.qualityScore));
      expect(mappedItem.notes, equals(item.notes));
    });
  });

  group('LocalDatasetRepository & Filtering Tests', () {
    late LocalDatasetRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({}); // Clean cache
      repository = LocalDatasetRepository();
    });

    test('getAllItems returns initial mock seed listings', () async {
      final list = await repository.getAllItems();
      expect(list.length, equals(2));
      expect(list[0].id, equals('mock_img_01'));
    });

    test('deleteItem successfully purges list index and cleans local storage', () async {
      await repository.getAllItems(); // Initialize cache
      await repository.deleteItem('mock_img_01');

      final list = await repository.getAllItems();
      expect(list.length, equals(1));
      expect(list[0].id, equals('mock_img_02'));
    });
  });

  group('DatasetListNotifier State Management & Exporter Tests', () {
    late LocalDatasetRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = LocalDatasetRepository();
    });

    ProviderContainer makeContainer() {
      final container = ProviderContainer(
        overrides: [
          datasetRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('Filtering dataset elements limits list contents accurately', () async {
      final container = makeContainer();
      final notifier = container.read(datasetListProvider.notifier);

      // Initial loading
      await notifier.refresh();
      expect(container.read(datasetListProvider).filteredItems.length, equals(2));

      // Apply filter for specific warehouse
      notifier.setFilters(warehouse: 'warehouse_south');
      expect(container.read(datasetListProvider).filteredItems.length, equals(1));
      expect(container.read(datasetListProvider).filteredItems.first.id, equals('mock_img_02'));
    });

    test('Triggering export updates state with absolute file path of ZIP archive', () async {
      final container = makeContainer();
      final notifier = container.read(datasetListProvider.notifier);

      await notifier.refresh();
      await notifier.triggerZipExport();

      final state = container.read(datasetListProvider);
      expect(state.exportZipPath, isNotNull);
      expect(state.exportZipPath, contains('.zip'));
    });
  });
}
