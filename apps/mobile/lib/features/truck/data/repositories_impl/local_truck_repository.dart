import 'package:drift/drift.dart' as drift;
import '../../domain/entities/truck.dart';
import '../../domain/repositories/truck_repository.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../../../utils/logger.dart';

class LocalTruckRepository implements TruckRepository {
  final db.AppDatabase _db;

  LocalTruckRepository(this._db);

  Truck _map(db.Truck data) {
    return Truck(
      id: data.id,
      truckNumber: data.truckNumber,
      vehicleNumber: data.vehicleNumber,
      driverName: data.driverName,
      driverMobile: data.driverMobile,
      company: data.company,
      warehouse: data.warehouse ?? '',
      status: TruckStatus.values.firstWhere((e) => e.name == data.status,
          orElse: () => TruckStatus.loading),
      createdDate: data.createdAt,
      updatedDate: data.updatedAt,
      wagonId: data.wagonId,
      completedDate: data.completedDate,
      totalLayers: data.totalLayers,
      totalCartons: data.totalCartons,
      totalDefects: data.totalDefects,
      notes: data.notes,
      syncStatus: SyncStatus.values.firstWhere((e) => e.name == data.syncStatus,
          orElse: () => SyncStatus.pending),
      isDeleted: data.isDeleted,
      isArchived: data.isArchived,
    );
  }

  @override
  Future<List<Truck>> getActiveTrucks() async {
    try {
      final rows = await (_db.select(_db.trucks)
            ..where((t) => t.isDeleted.equals(false)))
          .get();
      return rows.map(_map).toList();
    } catch (e, stack) {
      AppLogger.error('Failed reading truck records', e, stack);
      return [];
    }
  }

  @override
  Future<Truck?> getTruckById(String id) async {
    try {
      final row = await (_db.select(_db.trucks)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return row != null && !row.isDeleted ? _map(row) : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createTruck(Truck truck) async {
    await _db.transaction(() async {
      await _db.into(_db.trucks).insert(db.TrucksCompanion.insert(
            id: truck.id,
            wagonId: drift.Value(truck.wagonId),
            truckNumber: truck.truckNumber,
            vehicleNumber: truck.vehicleNumber,
            driverName: truck.driverName,
            driverMobile: drift.Value(truck.driverMobile),
            company: truck.company,
            status: truck.status.name,
            warehouse: drift.Value(truck.warehouse),
            completedDate: drift.Value(truck.completedDate),
            notes: drift.Value(truck.notes),
            totalLayers: drift.Value(truck.totalLayers),
            totalCartons: drift.Value(truck.totalCartons),
            totalDefects: drift.Value(truck.totalDefects),
            isArchived: drift.Value(truck.isArchived),
            createdAt: drift.Value(truck.createdDate),
            updatedAt: drift.Value(truck.updatedDate),
          ));

      await _db.into(_db.syncQueues).insert(db.SyncQueuesCompanion.insert(
            id: 'sync_t_${DateTime.now().millisecondsSinceEpoch}',
            entityId: truck.id,
            entityType: 'Truck',
            operation: 'INSERT',
            payloadData: '{}',
          ));
    });
    AppLogger.info('Created new truck record locally: ${truck.truckNumber}');
  }

  @override
  Future<void> updateTruck(Truck truck) async {
    await _db.transaction(() async {
      await (_db.update(_db.trucks)..where((t) => t.id.equals(truck.id)))
          .write(db.TrucksCompanion(
        wagonId: drift.Value(truck.wagonId),
        truckNumber: drift.Value(truck.truckNumber),
        vehicleNumber: drift.Value(truck.vehicleNumber),
        driverName: drift.Value(truck.driverName),
        driverMobile: drift.Value(truck.driverMobile),
        company: drift.Value(truck.company),
        status: drift.Value(truck.status.name),
        warehouse: drift.Value(truck.warehouse),
        completedDate: drift.Value(truck.completedDate),
        notes: drift.Value(truck.notes),
        totalLayers: drift.Value(truck.totalLayers),
        totalCartons: drift.Value(truck.totalCartons),
        totalDefects: drift.Value(truck.totalDefects),
        isArchived: drift.Value(truck.isArchived),
        updatedAt: drift.Value(DateTime.now()),
      ));

      await _db.into(_db.syncQueues).insert(db.SyncQueuesCompanion.insert(
            id: 'sync_t_${DateTime.now().millisecondsSinceEpoch}',
            entityId: truck.id,
            entityType: 'Truck',
            operation: 'UPDATE',
            payloadData: '{}',
          ));
    });
    AppLogger.info('Updated truck record: ${truck.truckNumber}');
  }

  @override
  Future<void> softDeleteTruck(String id) async {
    await _db.transaction(() async {
      await (_db.update(_db.trucks)..where((t) => t.id.equals(id)))
          .write(const db.TrucksCompanion(isDeleted: drift.Value(true)));

      await _db.into(_db.syncQueues).insert(db.SyncQueuesCompanion.insert(
            id: 'sync_t_${DateTime.now().millisecondsSinceEpoch}',
            entityId: id,
            entityType: 'Truck',
            operation: 'DELETE',
            payloadData: '{}',
          ));
    });
    AppLogger.info('Soft deleted truck: $id');
  }

  @override
  Future<void> archiveTruck(String id) async {
    await _db.transaction(() async {
      await (_db.update(_db.trucks)..where((t) => t.id.equals(id)))
          .write(const db.TrucksCompanion(isArchived: drift.Value(true)));

      await _db.into(_db.syncQueues).insert(db.SyncQueuesCompanion.insert(
            id: 'sync_t_${DateTime.now().millisecondsSinceEpoch}',
            entityId: id,
            entityType: 'Truck',
            operation: 'UPDATE',
            payloadData: '{"isArchived": true}',
          ));
    });
    AppLogger.info('Archived truck: $id');
  }

  @override
  Future<bool> isTruckNumberExists(String truckNumber,
      {String? excludeId, String? wagonId}) async {
    final normalizedTruckNumber = truckNumber.trim().toLowerCase();
    final query = _db.select(_db.trucks)
      ..where((t) => t.truckNumber.lower().equals(normalizedTruckNumber))
      ..where((t) => t.isDeleted.equals(false))
      ..where((t) => t.isArchived.equals(false));
    if (wagonId == null) {
      query.where((t) => t.wagonId.isNull());
    } else {
      query.where((t) => t.wagonId.equals(wagonId));
    }
    if (excludeId != null) {
      query.where((t) => t.id.isNotValue(excludeId));
    }
    final rows = await query.get();
    return rows.isNotEmpty;
  }

  @override
  Future<void> clearAllData() async {
    await _db.delete(_db.trucks).go();
  }

  @override
  Future<void> loadDemoData() async {
    await _db.transaction(() async {
      final now = DateTime(2026, 7, 21, 18, 0);
      await _db.into(_db.trucks).insert(db.TrucksCompanion.insert(
            id: 'sheet_truck_1965',
            truckNumber: '1965',
            vehicleNumber: '1965',
            driverName: 'Ramesh Kumar',
            driverMobile: const drift.Value('+91 98765 1965'),
            company: 'CGS Logistics',
            warehouse: const drift.Value('PAMOHI'),
            status: TruckStatus.completed.name,
            completedDate: drift.Value(now),
            createdAt: drift.Value(now.subtract(const Duration(hours: 8))),
            updatedAt: drift.Value(now),
            totalLayers: const drift.Value(15),
            totalCartons: const drift.Value(760),
            totalDefects: const drift.Value(2),
            wagonId: const drift.Value('sheet_wagon_10866'),
          ));

      await _db.into(_db.trucks).insert(db.TrucksCompanion.insert(
            id: 'sheet_truck_3459',
            truckNumber: '3459',
            vehicleNumber: '3459',
            driverName: 'Suresh Patel',
            driverMobile: const drift.Value('+91 98765 3459'),
            company: 'CGS Logistics',
            warehouse: const drift.Value('PAMOHI'),
            status: TruckStatus.completed.name,
            completedDate: drift.Value(now),
            createdAt: drift.Value(now.subtract(const Duration(hours: 7))),
            updatedAt: drift.Value(now),
            totalLayers: const drift.Value(16),
            totalCartons: const drift.Value(840),
            totalDefects: const drift.Value(1),
            wagonId: const drift.Value('sheet_wagon_10866'),
          ));

      await _db.into(_db.trucks).insert(db.TrucksCompanion.insert(
            id: 'sheet_truck_4076',
            truckNumber: '4076',
            vehicleNumber: '4076',
            driverName: 'Mohan Singh',
            driverMobile: const drift.Value('+91 98765 4076'),
            company: 'CGS Logistics',
            warehouse: const drift.Value('PAMOHI'),
            status: TruckStatus.completed.name,
            completedDate: drift.Value(now),
            createdAt: drift.Value(now.subtract(const Duration(hours: 6))),
            updatedAt: drift.Value(now),
            totalLayers: const drift.Value(16),
            totalCartons: const drift.Value(1000),
            totalDefects: const drift.Value(3),
            wagonId: const drift.Value('sheet_wagon_10866'),
          ));

      await _db.into(_db.trucks).insert(db.TrucksCompanion.insert(
            id: 'sheet_truck_1671',
            truckNumber: '1671',
            vehicleNumber: '1671',
            driverName: 'Vijay Yadav',
            driverMobile: const drift.Value('+91 98765 1671'),
            company: 'CGS Logistics',
            warehouse: const drift.Value('PAMOHI'),
            status: TruckStatus.completed.name,
            completedDate: drift.Value(now),
            createdAt: drift.Value(now.subtract(const Duration(hours: 5))),
            updatedAt: drift.Value(now),
            totalLayers: const drift.Value(16),
            totalCartons: const drift.Value(950),
            totalDefects: const drift.Value(2),
            wagonId: const drift.Value('sheet_wagon_10866'),
          ));

      await _db.into(_db.trucks).insert(db.TrucksCompanion.insert(
            id: 'sheet_truck_628',
            truckNumber: '628',
            vehicleNumber: '628',
            driverName: 'Rajesh Verma',
            driverMobile: const drift.Value('+91 98765 00628'),
            company: 'CGS Logistics',
            warehouse: const drift.Value('PAMOHI'),
            status: TruckStatus.completed.name,
            completedDate: drift.Value(now),
            createdAt: drift.Value(now.subtract(const Duration(hours: 4))),
            updatedAt: drift.Value(now),
            totalLayers: const drift.Value(16),
            totalCartons: const drift.Value(1005),
            totalDefects: const drift.Value(2),
            wagonId: const drift.Value('sheet_wagon_10866'),
          ));
    });
  }
}
