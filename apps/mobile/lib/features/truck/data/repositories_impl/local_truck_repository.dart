import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/truck.dart';
import '../../domain/repositories/truck_repository.dart';
import '../models/truck_model.dart';
import '../../../../utils/logger.dart';

class LocalTruckRepository implements TruckRepository {
  static const String _storageKey = 'cached_truck_records_v2';

  LocalTruckRepository();

  Future<void> _writeToCache(List<Truck> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> rawMaps = list.map((e) => TruckModel.toJson(e)).toList();
      final rawJson = json.encode(rawMaps);
      await prefs.setString(_storageKey, rawJson);
    } catch (e, stack) {
      AppLogger.error('Failed writing truck database cache', e, stack);
    }
  }

  @override
  Future<List<Truck>> getActiveTrucks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString(_storageKey);
      
      if (cachedStr == null) {
        // Feed initial mock trucks if database is empty for warehouse verification demo
        final defaultMocks = _generateMockTrucks();
        await _writeToCache(defaultMocks);
        return defaultMocks;
      }

      final List<dynamic> rawList = json.decode(cachedStr);
      final List<Truck> allTrucks = rawList.map((e) => TruckModel.fromJson(e as Map<String, dynamic>)).toList();
      
      // Filter out soft-deleted records
      return allTrucks.where((t) => !t.isDeleted).toList();
    } catch (e, stack) {
      AppLogger.error('Failed reading truck records', e, stack);
      return [];
    }
  }

  @override
  Future<Truck?> getTruckById(String id) async {
    final list = await getActiveTrucks();
    try {
      return list.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createTruck(Truck truck) async {
    final list = await getActiveTrucks();
    list.add(truck);
    await _writeToCache(list);
    AppLogger.info('Created new truck record locally: ${truck.truckNumber}');
  }

  @override
  Future<void> updateTruck(Truck truck) async {
    final list = await getActiveTrucks();
    final index = list.indexWhere((element) => element.id == truck.id);
    if (index != -1) {
      list[index] = truck.copyWith(updatedDate: DateTime.now());
      await _writeToCache(list);
      AppLogger.info('Updated truck record: ${truck.truckNumber}');
    }
  }

  @override
  Future<void> softDeleteTruck(String id) async {
    final list = await getActiveTrucks();
    final index = list.indexWhere((element) => element.id == id);
    if (index != -1) {
      list[index] = list[index].copyWith(isDeleted: true, updatedDate: DateTime.now());
      await _writeToCache(list);
      AppLogger.info('Soft deleted truck: $id');
    }
  }

  @override
  Future<void> archiveTruck(String id) async {
    final list = await getActiveTrucks();
    final index = list.indexWhere((element) => element.id == id);
    if (index != -1) {
      list[index] = list[index].copyWith(isArchived: true, updatedDate: DateTime.now());
      await _writeToCache(list);
      AppLogger.info('Archived truck: $id');
    }
  }

  @override
  Future<bool> isTruckNumberExists(String truckNumber, {String? excludeId}) async {
    final list = await getActiveTrucks();
    return list.any((t) => t.truckNumber.toLowerCase() == truckNumber.toLowerCase() && t.id != excludeId);
  }

  List<Truck> _generateMockTrucks() {
    final now = DateTime.now();
    return [
      Truck(
        id: 'mock_t1',
        truckNumber: 'TX-9908-AB',
        vehicleNumber: 'V-101',
        driverName: 'John Doe',
        company: 'Swift Carriers',
        warehouse: 'Austin Fulfillment South',
        status: TruckStatus.loading,
        createdDate: now.subtract(const Duration(hours: 4)),
        updatedDate: now.subtract(const Duration(hours: 4)),
        totalLayers: 3,
        totalCartons: 72,
        totalDefects: 2,
        wagonId: 'mock_w1',
      ),
      Truck(
        id: 'mock_t2',
        truckNumber: 'CA-4432-XY',
        vehicleNumber: 'V-205',
        driverName: 'Alice Smith',
        company: 'Pacific Freight',
        warehouse: 'Austin Fulfillment South',
        status: TruckStatus.completed,
        createdDate: now.subtract(const Duration(days: 1)),
        updatedDate: now.subtract(const Duration(hours: 12)),
        completedDate: now.subtract(const Duration(hours: 12)),
        totalLayers: 10,
        totalCartons: 240,
        totalDefects: 1,
        wagonId: 'mock_w1',
      ),
    ];
  }
}
