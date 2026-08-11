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
    final truck = await (_db.select(_db.trucks)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    if (truck == null || truck.isDeleted) return;
    await _db.transaction(() async {
      final layers = await (_db.select(_db.layers)
            ..where((layer) =>
                layer.truckId.equals(id) & layer.isDeleted.equals(false)))
          .get();
      final layerIds = layers.map((layer) => layer.id).toList(growable: false);

      await (_db.update(_db.trucks)..where((t) => t.id.equals(id)))
          .write(db.TrucksCompanion(
        isDeleted: const drift.Value(true),
        updatedAt: drift.Value(DateTime.now()),
      ));
      await (_db.update(_db.layers)..where((layer) => layer.truckId.equals(id)))
          .write(db.LayersCompanion(
        isDeleted: const drift.Value(true),
        updatedAt: drift.Value(DateTime.now()),
      ));
      if (layerIds.isNotEmpty) {
        await (_db.update(_db.detections)
              ..where((detection) => detection.layerId.isIn(layerIds)))
            .write(db.DetectionsCompanion(
          isDeleted: const drift.Value(true),
          updatedAt: drift.Value(DateTime.now()),
        ));
      }
      await (_db.update(_db.loadingSessions)
            ..where((session) => session.truckId.equals(id)))
          .write(db.LoadingSessionsCompanion(
        isDeleted: const drift.Value(true),
        status: const drift.Value('cancelled'),
        endTime: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      ));

      await _db.into(_db.auditLogs).insert(db.AuditLogsCompanion.insert(
            id: 'audit_truck_delete_${DateTime.now().microsecondsSinceEpoch}',
            entityId: id,
            entityType: 'Truck',
            action: 'delete',
            userId: 'local_operator',
            details: drift.Value(
                'Voided truck ${truck.truckNumber} and ${layers.length} child layers.'),
          ));

      await _db.into(_db.syncQueues).insert(db.SyncQueuesCompanion.insert(
            id: 'sync_t_${DateTime.now().microsecondsSinceEpoch}',
            entityId: id,
            entityType: 'Truck',
            operation: 'DELETE',
            payloadData: '{"cascadeChildren":true}',
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
  Future<void> loadDemoData({String? operatorName}) async {
    await _db.transaction(() async {
      final now = DateTime.now();
      Future<void> add(
              {required String id,
              required String wagonId,
              required String number,
              required String vehicle,
              required String driver,
              required String mobile,
              required String company,
              required String warehouse,
              required TruckStatus status,
              required int layers,
              required int cartons,
              required int defects,
              int daysAgo = 0,
              bool archived = false,
              bool deleted = false,
              String? notes}) =>
          _db.into(_db.trucks).insert(db.TrucksCompanion.insert(
                id: id,
                wagonId: drift.Value(wagonId),
                truckNumber: number,
                vehicleNumber: vehicle,
                driverName: driver,
                driverMobile: drift.Value(mobile),
                company: company,
                warehouse: drift.Value(warehouse),
                status: status.name,
                totalLayers: drift.Value(layers),
                totalCartons: drift.Value(cartons),
                totalDefects: drift.Value(defects),
                isArchived: drift.Value(archived),
                isDeleted: drift.Value(deleted),
                notes: drift.Value(notes),
                completedDate: status == TruckStatus.completed
                    ? drift.Value(now.subtract(Duration(days: daysAgo)))
                    : const drift.Value.absent(),
                createdAt: drift.Value(
                    now.subtract(Duration(days: daysAgo, hours: 6))),
                updatedAt: drift.Value(now.subtract(Duration(days: daysAgo))),
              ));

      await add(
          id: 'demo_truck_active_1',
          wagonId: 'demo_wagon_active',
          number: 'TRK-240811-A',
          vehicle: 'AS 01 KC 4821',
          driver: 'Ramesh Das',
          mobile: '+91 98765 41021',
          company: 'Vinayak Contract Logistics',
          warehouse: 'Pamohi DC',
          status: TruckStatus.loading,
          layers: 3,
          cartons: 160,
          defects: 2,
          notes: 'Active truck with mixed items and correction history.');
      await add(
          id: 'demo_truck_completed_1',
          wagonId: 'demo_wagon_completed',
          number: 'TRK-240806-A',
          vehicle: 'DL 01 MA 7732',
          driver: 'Sanjay Kumar',
          mobile: '+91 98110 47732',
          company: 'North East Freight Systems',
          warehouse: 'Guwahati ICD',
          status: TruckStatus.completed,
          layers: 2,
          cartons: 120,
          defects: 0,
          daysAgo: 5);
      await add(
          id: 'demo_truck_completed_2',
          wagonId: 'demo_wagon_completed',
          number: 'TRK-240806-B',
          vehicle: 'HR 55 AB 9210',
          driver: 'Manoj Yadav',
          mobile: '+91 98990 29210',
          company: 'North East Freight Systems',
          warehouse: 'Guwahati ICD',
          status: TruckStatus.completed,
          layers: 2,
          cartons: 120,
          defects: 1,
          daysAgo: 5);
      await add(
          id: 'demo_truck_archived',
          wagonId: 'demo_wagon_archived',
          number: 'TRK-240712-H',
          vehicle: 'MH 04 JK 1188',
          driver: 'Iqbal Sheikh',
          mobile: '+91 98201 31188',
          company: 'Western Corridor Cargo',
          warehouse: 'Delhi NCR Hub',
          status: TruckStatus.completed,
          layers: 2,
          cartons: 90,
          defects: 0,
          daysAgo: 30,
          archived: true);
      const enterpriseVehicles = [
        'WB 23 F 4101',
        'WB 23 F 4102',
        'WB 23 F 4103',
        'WB 23 F 4104',
        'WB 23 F 4105',
        'WB 23 F 4106',
      ];
      const enterpriseDrivers = [
        'Amit Roy',
        'Deepak Mandal',
        'Niraj Das',
        'Prakash Shah',
        'Subhash Paul',
        'Vikram Nath',
      ];
      for (var index = 0; index < 6; index++) {
        final layerCount = 15 + index;
        await add(
          id: 'demo_truck_enterprise_${index + 1}',
          wagonId: 'demo_wagon_enterprise',
          number: 'ENT-TRK-${index + 1}',
          vehicle: enterpriseVehicles[index],
          driver: enterpriseDrivers[index],
          mobile: '+91 98000 4100${index + 1}',
          company: 'Eastern Enterprise Logistics',
          warehouse: 'Guwahati ICD',
          status: index < 4 ? TruckStatus.completed : TruckStatus.loading,
          layers: layerCount,
          cartons: layerCount * 40,
          defects: index % 3 == 0 ? 0 : 1,
          notes: 'Enterprise wagon truck ${index + 1} of 6.',
        );
      }
      await add(
          id: 'demo_truck_deleted',
          wagonId: 'demo_wagon_active',
          number: 'DELETED-TRUCK',
          vehicle: 'AS 00 XX 0000',
          driver: 'Hidden Operator',
          mobile: 'N/A',
          company: 'Hidden',
          warehouse: 'Hidden',
          status: TruckStatus.loading,
          layers: 1,
          cartons: 10,
          defects: 0,
          deleted: true,
          notes: 'Soft-deleted truck; must remain hidden.');
    });
  }
}
