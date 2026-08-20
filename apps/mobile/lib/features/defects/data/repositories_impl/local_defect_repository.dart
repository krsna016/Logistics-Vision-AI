import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/defect.dart';
import '../../domain/repositories/defect_repository.dart';
import '../models/defect_model.dart';
import '../../../camera/domain/entities/detection.dart';
import '../../../../utils/logger.dart';

class LocalDefectRepository implements DefectRepository {
  static const String _storageKey = 'cached_defect_records_v1';

  LocalDefectRepository({Object? database});

  Future<void> _writeToCache(List<DefectRecord> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> rawMaps =
          list.map((e) => DefectModel.toJson(e)).toList();
      final rawJson = json.encode(rawMaps);
      await prefs.setString(_storageKey, rawJson);
    } catch (e, stack) {
      AppLogger.error('Failed writing defect database cache', e, stack);
    }
  }

  Future<List<DefectRecord>> _readAllDefects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString(_storageKey);
      if (cachedStr == null) {
        // Seed initial mock defects
        final defaultMocks = _generateMockDefects();
        await _writeToCache(defaultMocks);
        return defaultMocks;
      }
      final rawList = json.decode(cachedStr) as List<dynamic>;
      return rawList
          .map((e) => DefectModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      AppLogger.error('Failed reading defects list', e, stack);
      return [];
    }
  }

  @override
  Future<void> saveDefect(DefectRecord defect) async {
    final list = await _readAllDefects();
    list.add(defect);
    await _writeToCache(list);
    AppLogger.info(
        'Saved defect record ${defect.id} (Type: ${defect.defectType.name})');
  }

  @override
  Future<List<DefectRecord>> getDefectsByLayer(String layerId) async {
    final list = await _readAllDefects();
    return list.where((d) => d.layerId == layerId).toList();
  }

  @override
  Future<List<DefectRecord>> getDefectsByTruck(String truckId) async {
    // Note: Normally we fetch matching layer IDs for the truck and filter defects
    // Here we perform simple ID contains mapping for demonstration simplicity.
    final list = await _readAllDefects();
    return list.where((d) => d.layerId.contains(truckId)).toList();
  }

  @override
  Future<void> verifyDefect(String id,
      {required bool confirmedByOperator, String? notes}) async {
    final list = await _readAllDefects();
    final index = list.indexWhere((element) => element.id == id);
    if (index != -1) {
      list[index] = list[index].copyWith(
        confirmedByOperator: confirmedByOperator,
        notes: notes,
      );
      await _writeToCache(list);
      AppLogger.info('Verified defect $id: confirmed=$confirmedByOperator');
    }
  }

  List<DefectRecord> _generateMockDefects() {
    final now = DateTime.now();
    return [
      DefectRecord(
        id: 'mock_d1',
        layerId: 'mock_l1',
        defectType: DefectType.crushed,
        boundingBox:
            const BoundingBox(xMin: 0.15, yMin: 0.22, xMax: 0.35, yMax: 0.45),
        severity: DefectSeverity.medium,
        confidence: 0.88,
        modelVersion: '1.0.0-DefectNet',
        detectedAt: now.subtract(const Duration(hours: 3)),
      ),
      DefectRecord(
        id: 'mock_d2',
        layerId: 'mock_l1',
        defectType: DefectType.torn,
        boundingBox:
            const BoundingBox(xMin: 0.60, yMin: 0.40, xMax: 0.85, yMax: 0.70),
        severity: DefectSeverity.low,
        confidence: 0.79,
        modelVersion: '1.0.0-DefectNet',
        detectedAt: now.subtract(const Duration(hours: 3)),
      ),
      DefectRecord(
        id: 'mock_d3',
        layerId: 'mock_l3',
        defectType: DefectType.wet,
        boundingBox:
            const BoundingBox(xMin: 0.45, yMin: 0.35, xMax: 0.70, yMax: 0.65),
        severity: DefectSeverity.high,
        confidence: 0.92,
        notes: 'Wet stains visible on bottom flap',
        modelVersion: '1.0.0-DefectNet',
        detectedAt: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }
}
