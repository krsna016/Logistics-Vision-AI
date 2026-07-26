import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/wagon.dart';
import '../../domain/repositories/wagon_repository.dart';
import '../models/wagon_model.dart';
import '../../../../utils/logger.dart';

class LocalWagonRepository implements WagonRepository {
  static const String _storageKey = 'cached_wagon_records_v2';

  LocalWagonRepository();

  Future<void> _writeToCache(List<Wagon> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> rawMaps = list.map((e) => WagonModel.toJson(e)).toList();
      final rawJson = json.encode(rawMaps);
      await prefs.setString(_storageKey, rawJson);
    } catch (e, stack) {
      AppLogger.error('Failed writing wagon database cache', e, stack);
    }
  }

  @override
  Future<List<Wagon>> getActiveWagons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString(_storageKey);
      
      if (cachedStr == null || cachedStr == '[]') {
        final defaultMocks = _generateMockWagons();
        await _writeToCache(defaultMocks);
        return defaultMocks;
      }

      final List<dynamic> rawList = json.decode(cachedStr);
      final List<Wagon> allWagons = rawList.map((e) => WagonModel.fromJson(e as Map<String, dynamic>)).toList();
      
      return allWagons;
    } catch (e, stack) {
      AppLogger.error('Failed reading wagon records', e, stack);
      return [];
    }
  }

  @override
  Future<Wagon?> getWagonById(String id) async {
    final list = await getActiveWagons();
    try {
      return list.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createWagon(Wagon wagon) async {
    final list = await getActiveWagons();
    list.add(wagon);
    await _writeToCache(list);
    AppLogger.info('Created new wagon record locally: ${wagon.wagonNumber}');
  }

  @override
  Future<void> updateWagon(Wagon wagon) async {
    final list = await getActiveWagons();
    final index = list.indexWhere((element) => element.id == wagon.id);
    if (index != -1) {
      list[index] = wagon.copyWith(updatedAt: DateTime.now());
      await _writeToCache(list);
      AppLogger.info('Updated wagon record: ${wagon.wagonNumber}');
    }
  }

  @override
  Future<void> deleteWagon(String id) async {
    final list = await getActiveWagons();
    final index = list.indexWhere((element) => element.id == id);
    if (index != -1) {
      final wagon = list.removeAt(index);
      await _writeToCache(list);
      AppLogger.info('Deleted wagon record locally: ${wagon.wagonNumber}');
    }
  }

  @override
  Future<bool> isWagonNumberExists(String wagonNumber, {String? excludeId}) async {
    final list = await getActiveWagons();
    return list.any((t) => t.wagonNumber.toLowerCase() == wagonNumber.toLowerCase() && t.id != excludeId);
  }

  List<Wagon> _generateMockWagons() {
    final now = DateTime.now();
    return [
      Wagon(
        id: 'mock_w1',
        wagonNumber: 'W-1002-IND',
        origin: 'Austin Fulfillment South',
        destination: 'Dallas Logistics Hub',
        loadingDate: now,
        expectedTruckCount: 3,
        completedTruckCount: 1,
        status: WagonStatus.loading,
        remarks: 'Priority cargo load',
        createdAt: now.subtract(const Duration(hours: 12)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      Wagon(
        id: 'mock_w2',
        wagonNumber: 'W-3004-TEX',
        origin: 'Austin Fulfillment South',
        destination: 'Houston Rail Terminal',
        loadingDate: now.add(const Duration(days: 1)),
        expectedTruckCount: 5,
        completedTruckCount: 0,
        status: WagonStatus.planning,
        remarks: 'Bulk materials loading planned',
        createdAt: now.subtract(const Duration(hours: 4)),
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
    ];
  }
}
