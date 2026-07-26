import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/layer.dart';
import '../../domain/repositories/layer_repository.dart';
import '../models/layer_model.dart';
import '../../../../utils/logger.dart';

class LocalLayerRepository implements LayerRepository {
  static const String _storageKey = 'cached_layer_records_v1';

  LocalLayerRepository();

  Future<void> _writeToCache(List<LayerRecord> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> rawMaps = list.map((e) => LayerModel.toJson(e)).toList();
      final rawJson = json.encode(rawMaps);
      await prefs.setString(_storageKey, rawJson);
    } catch (e, stack) {
      AppLogger.error('Failed writing layer database cache', e, stack);
    }
  }

  @override
  Future<List<LayerRecord>> getLayersByTruck(String truckId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString(_storageKey);

      if (cachedStr == null || cachedStr == '[]') {
        // Feed initial mock layers if database is empty for our mockup demo
        final defaultMocks = _generateMockLayers();
        await _writeToCache(defaultMocks);
        return defaultMocks.where((l) => l.truckId == truckId && !l.isDeleted).toList();
      }

      final List<dynamic> rawList = json.decode(cachedStr);
      final List<LayerRecord> allLayers = rawList.map((e) => LayerModel.fromJson(e as Map<String, dynamic>)).toList();

      return allLayers.where((l) => l.truckId == truckId && !l.isDeleted).toList();
    } catch (e, stack) {
      AppLogger.error('Failed reading layer records', e, stack);
      return [];
    }
  }

  @override
  Future<void> saveLayer(LayerRecord layer) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedStr = prefs.getString(_storageKey);
    final List<LayerRecord> allLayers = [];

    if (cachedStr != null) {
      final List<dynamic> rawList = json.decode(cachedStr);
      allLayers.addAll(rawList.map((e) => LayerModel.fromJson(e as Map<String, dynamic>)));
    } else {
      allLayers.addAll(_generateMockLayers());
    }

    allLayers.add(layer);
    await _writeToCache(allLayers);
    AppLogger.info('Saved layer number ${layer.layerNumber} for truck ${layer.truckId}');
  }

  @override
  Future<void> updateLayer(LayerRecord layer) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedStr = prefs.getString(_storageKey);
    if (cachedStr == null) return;

    final List<dynamic> rawList = json.decode(cachedStr);
    final List<LayerRecord> allLayers = rawList.map((e) => LayerModel.fromJson(e as Map<String, dynamic>)).toList();

    final index = allLayers.indexWhere((element) => element.id == layer.id);
    if (index != -1) {
      allLayers[index] = layer.copyWith(updatedAt: DateTime.now());
      await _writeToCache(allLayers);
      AppLogger.info('Updated layer record: ${layer.id}');
    }
  }

  @override
  Future<void> softDeleteLayer(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedStr = prefs.getString(_storageKey);
    if (cachedStr == null) return;

    final List<dynamic> rawList = json.decode(cachedStr);
    final List<LayerRecord> allLayers = rawList.map((e) => LayerModel.fromJson(e as Map<String, dynamic>)).toList();

    final index = allLayers.indexWhere((element) => element.id == id);
    if (index != -1) {
      allLayers[index] = allLayers[index].copyWith(isDeleted: true, updatedAt: DateTime.now());
      await _writeToCache(allLayers);
      AppLogger.info('Soft deleted layer: $id');
    }
  }

  @override
  Future<bool> isLayerNumberExists(String truckId, int layerNumber) async {
    final list = await getLayersByTruck(truckId);
    return list.any((l) => l.layerNumber == layerNumber);
  }

  List<LayerRecord> _generateMockLayers() {
    final now = DateTime.now();
    return [
      LayerRecord(
        id: 'mock_l1',
        truckId: 'mock_t1',
        layerNumber: 1,
        cartonCount: 24,
        timestamp: now.subtract(const Duration(hours: 3)),
        operatorId: 'usr_loader_01',
        modelVersion: '1.0.0-YOLOv8n',
        averageConfidence: 0.94,
        createdAt: now.subtract(const Duration(hours: 3)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
      LayerRecord(
        id: 'mock_l2',
        truckId: 'mock_t1',
        layerNumber: 2,
        cartonCount: 24,
        timestamp: now.subtract(const Duration(hours: 2)),
        operatorId: 'usr_loader_01',
        modelVersion: '1.0.0-YOLOv8n',
        averageConfidence: 0.96,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      LayerRecord(
        id: 'mock_l3',
        truckId: 'mock_t1',
        layerNumber: 3,
        cartonCount: 24,
        timestamp: now.subtract(const Duration(hours: 1)),
        operatorId: 'usr_loader_01',
        modelVersion: '1.0.0-YOLOv8n',
        averageConfidence: 0.91,
        notes: 'Slight carton slip corrected manually',
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }
}
