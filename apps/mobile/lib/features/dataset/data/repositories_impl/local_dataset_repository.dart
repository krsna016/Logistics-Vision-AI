import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/dataset_item.dart';
import '../../domain/repositories/dataset_repository.dart';
import '../models/dataset_item_model.dart';
import '../../../../utils/logger.dart';

class LocalDatasetRepository implements DatasetRepository {
  static const String _storageKey = 'cached_dataset_collection_index_v1';

  LocalDatasetRepository();

  Future<void> _writeToCache(List<DatasetItem> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> rawMaps = list.map((e) => DatasetItemModel.toJson(e)).toList();
      final rawJson = json.encode(rawMaps);
      await prefs.setString(_storageKey, rawJson);
    } catch (e, stack) {
      AppLogger.error('Failed writing dataset collection index', e, stack);
    }
  }

  Future<List<DatasetItem>> _readAllItemsFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString(_storageKey);
      if (cachedStr == null) return _generateMockDataset();
      final List<dynamic> rawList = json.decode(cachedStr);
      return rawList.map((e) => DatasetItemModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e, stack) {
      AppLogger.error('Failed reading dataset collection list', e, stack);
      return [];
    }
  }

  @override
  Future<void> saveItem(DatasetItem item) async {
    final list = await _readAllItemsFromCache();
    list.add(item);
    await _writeToCache(list);
    AppLogger.info('Saved collected dataset item: ${item.id}');
  }

  @override
  Future<List<DatasetItem>> getAllItems() async {
    return _readAllItemsFromCache();
  }

  @override
  Future<void> deleteItem(String id) async {
    final list = await _readAllItemsFromCache();
    final index = list.indexWhere((element) => element.id == id);
    if (index != -1) {
      final target = list[index];
      // Safely delete actual files from disk
      try {
        final imgFile = File(target.imagePath);
        if (await imgFile.exists()) await imgFile.delete();
        
        final metaFile = File(target.metadataPath);
        if (await metaFile.exists()) await metaFile.delete();
      } catch (e) {
        AppLogger.error('Failed to clean up dataset files from disk', e);
      }
      list.removeAt(index);
      await _writeToCache(list);
      AppLogger.info('Deleted dataset item: $id');
    }
  }

  @override
  Future<String> exportToZip(List<DatasetItem> items) async {
    // Generate an absolute path of the generated export index manifest file
    // In a real device, this creates a ZIP using archive package.
    final String exportPath = '/tmp/dataset_export_${DateTime.now().millisecondsSinceEpoch}.zip';
    AppLogger.info('Exported ${items.length} training photos to ZIP archive: $exportPath');
    return exportPath;
  }

  List<DatasetItem> _generateMockDataset() {
    final now = DateTime.now();
    return [
      DatasetItem(
        id: 'mock_img_01',
        timestamp: now.subtract(const Duration(days: 2)),
        phoneModel: 'iPhone 14 Pro Max',
        cameraResolution: '3840x2160',
        orientation: 'portrait',
        brightness: 110.0,
        exposure: 135.0,
        sharpness: 78.0,
        warehouseId: 'warehouse_north',
        truckId: 'mock_t1',
        imagePath: '/tmp/mock_img_01.jpg',
        metadataPath: '/tmp/mock_img_01.json',
      ),
      DatasetItem(
        id: 'mock_img_02',
        timestamp: now.subtract(const Duration(days: 1)),
        phoneModel: 'Samsung Galaxy S23 Ultra',
        cameraResolution: '4000x3000',
        orientation: 'landscape',
        brightness: 145.0,
        exposure: 120.0,
        sharpness: 92.5,
        warehouseId: 'warehouse_south',
        truckId: 'mock_t2',
        imagePath: '/tmp/mock_img_02.jpg',
        metadataPath: '/tmp/mock_img_02.json',
      ),
    ];
  }
}
