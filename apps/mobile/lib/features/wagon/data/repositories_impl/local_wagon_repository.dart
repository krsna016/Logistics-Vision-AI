import './../../../../core/utils/field_normalizer.dart';

import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import '../../domain/entities/wagon.dart';
import '../../domain/repositories/wagon_repository.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../../../utils/logger.dart';

class LocalWagonRepository implements WagonRepository {
  final db.AppDatabase _db;

  LocalWagonRepository(this._db);

  Wagon _map(db.Wagon data) {
    final decodedItems = <WagonItem>[];
    try {
      final decoded = jsonDecode(data.itemManifestJson) as List<dynamic>;
      decodedItems.addAll(decoded
          .whereType<Map<String, dynamic>>()
          .map(WagonItem.fromJson)
          .where((item) => item.name.isNotEmpty && item.quantity > 0));
    } catch (_) {
      // Old or malformed local data is treated as an empty manifest.
    }
    return Wagon(
      id: data.id,
      wagonNumber: data.wagonNumber,
      origin: data.origin ?? '',
      destination: data.destination ?? '',
      loadingDate: data.loadingDate ?? DateTime.now(),
      expectedTruckCount: data.expectedTruckCount,
      completedTruckCount: data.completedTruckCount,
      status: WagonStatus.values.firstWhere((e) => e.name == data.status,
          orElse: () => WagonStatus.planning),
      remarks: data.remarks,
      items: decodedItems,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  @override
  Future<List<Wagon>> getActiveWagons() async {
    try {
      final rows = await (_db.select(_db.wagons)
            ..where((t) => t.isDeleted.equals(false)))
          .get();
      return rows.map(_map).toList();
    } catch (e, stack) {
      AppLogger.error('Failed reading wagon records', e, stack);
      return [];
    }
  }

  @override
  Future<Wagon?> getWagonById(String id) async {
    try {
      final row = await (_db.select(_db.wagons)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return row != null && !row.isDeleted ? _map(row) : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createWagon(Wagon wagon) async {
    await _db.transaction(() async {
      await _db.into(_db.wagons).insert(db.WagonsCompanion.insert(
            id: wagon.id,
            wagonNumber: wagon.wagonNumber,
            status: wagon.status.name,
            expectedTruckCount: wagon.expectedTruckCount,
            origin: drift.Value(wagon.origin),
            destination: drift.Value(wagon.destination),
            loadingDate: drift.Value(wagon.loadingDate),
            remarks: drift.Value(wagon.remarks),
            itemManifestJson: drift.Value(
                jsonEncode(wagon.items.map((item) => item.toJson()).toList())),
            completedTruckCount: drift.Value(wagon.completedTruckCount),
            createdAt: drift.Value(wagon.createdAt),
            updatedAt: drift.Value(wagon.updatedAt),
          ));
    });
    AppLogger.info('Created new wagon record locally: ${wagon.wagonNumber}');
  }

  @override
  Future<void> updateWagon(Wagon wagon) async {
    await _db.transaction(() async {
      final existing = await (_db.select(_db.wagons)
            ..where((row) => row.id.equals(wagon.id)))
          .getSingleOrNull();
      if (existing == null || existing.isDeleted) return;
      final nextVersion = existing.version + 1;
      await (_db.update(_db.wagons)..where((t) => t.id.equals(wagon.id)))
          .write(db.WagonsCompanion(
        wagonNumber: drift.Value(wagon.wagonNumber),
        status: drift.Value(wagon.status.name),
        expectedTruckCount: drift.Value(wagon.expectedTruckCount),
        origin: drift.Value(wagon.origin),
        destination: drift.Value(wagon.destination),
        loadingDate: drift.Value(wagon.loadingDate),
        remarks: drift.Value(wagon.remarks),
        itemManifestJson: drift.Value(
            jsonEncode(wagon.items.map((item) => item.toJson()).toList())),
        completedTruckCount: drift.Value(wagon.completedTruckCount),
        version: drift.Value(nextVersion),
        updatedAt: drift.Value(DateTime.now()),
      ));

      final changes = <String>[];
      if (existing.wagonNumber != wagon.wagonNumber)
        changes.add('Number: ${existing.wagonNumber} -> ${wagon.wagonNumber}');
      if (existing.status != wagon.status.name)
        changes.add('Status: ${existing.status} -> ${wagon.status.name}');
      if (existing.origin != wagon.origin)
        changes.add('Origin: ${existing.origin} -> ${wagon.origin}');
      if (existing.destination != wagon.destination)
        changes.add('Dest: ${existing.destination} -> ${wagon.destination}');
      if (existing.remarks != wagon.remarks)
        changes.add('Remarks: ${existing.remarks} -> ${wagon.remarks}');

      final changeStr =
          changes.isEmpty ? 'No values changed' : changes.join(', ');
      AppLogger.info(
          'Updated wagon record: ${wagon.wagonNumber} | Changes: $changeStr');
    });
  }

  @override
  Future<void> deleteWagon(String id) async {
    final wagon = await (_db.select(_db.wagons)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
    if (wagon == null || wagon.isDeleted) return;
    await _db.transaction(() async {
      final trucks = await (_db.select(_db.trucks)
            ..where((truck) => truck.wagonId.equals(id)))
          .get();
      final truckIds = trucks.map((truck) => truck.id).toList(growable: false);
      final layers = truckIds.isEmpty
          ? <db.Layer>[]
          : await (_db.select(_db.layers)
                ..where((layer) => layer.truckId.isIn(truckIds)))
              .get();
      final sessions = truckIds.isEmpty
          ? <db.LoadingSession>[]
          : await (_db.select(_db.loadingSessions)
                ..where((session) =>
                    session.truckId.isIn(truckIds) &
                    session.isDeleted.equals(false)))
              .get();
      final layerIds = layers.map((layer) => layer.id).toList(growable: false);
      final wagonVersion = wagon.version + 1;

      await (_db.update(_db.wagons)..where((t) => t.id.equals(id))).write(
          db.WagonsCompanion(
              isDeleted: const drift.Value(true),
              version: drift.Value(wagonVersion),
              updatedAt: drift.Value(DateTime.now())) // soft delete
          );
      if (truckIds.isNotEmpty) {
        for (final truck in trucks.where((record) => !record.isDeleted)) {
          await (_db.update(_db.trucks)
                ..where((row) => row.id.equals(truck.id)))
              .write(db.TrucksCompanion(
            isDeleted: const drift.Value(true),
            version: drift.Value(truck.version + 1),
            updatedAt: drift.Value(DateTime.now()),
          ));
        }
        for (final layer in layers.where((record) => !record.isDeleted)) {
          await (_db.update(_db.layers)
                ..where((row) => row.id.equals(layer.id)))
              .write(db.LayersCompanion(
            isDeleted: const drift.Value(true),
            version: drift.Value(layer.version + 1),
            updatedAt: drift.Value(DateTime.now()),
          ));
        }
        for (final session in sessions) {
          await (_db.update(_db.loadingSessions)
                ..where((row) => row.id.equals(session.id)))
              .write(db.LoadingSessionsCompanion(
            isDeleted: const drift.Value(true),
            status: const drift.Value('cancelled'),
            endTime: drift.Value(DateTime.now()),
            version: drift.Value(session.version + 1),
            updatedAt: drift.Value(DateTime.now()),
          ));
        }
      }
      if (layerIds.isNotEmpty) {
        await (_db.update(_db.detections)
              ..where((detection) => detection.layerId.isIn(layerIds)))
            .write(db.DetectionsCompanion(
          isDeleted: const drift.Value(true),
          updatedAt: drift.Value(DateTime.now()),
        ));
      }
      await (_db.update(_db.digitalRegisters)
            ..where((register) => register.wagonId.equals(id)))
          .write(db.DigitalRegistersCompanion(
        isDeleted: const drift.Value(true),
        updatedAt: drift.Value(DateTime.now()),
      ));

      await _db.into(_db.auditLogs).insert(db.AuditLogsCompanion.insert(
            id: 'audit_wagon_delete_${DateTime.now().microsecondsSinceEpoch}',
            entityId: id,
            entityType: 'Wagon',
            action: 'delete',
            userId: 'local_operator',
            details: drift.Value(
                'Voided wagon ${wagon.wagonNumber}, ${trucks.length} trucks and ${layers.length} layers.'),
          ));
    });
    AppLogger.info('Deleted wagon record locally: $id');
  }

  @override
  Future<bool> isWagonNumberExists(String wagonNumber,
      {String? excludeId}) async {
    final normalizedWagonNumber = wagonNumber.trim().toLowerCase();
    final query = _db.select(_db.wagons)
      ..where((t) => t.wagonNumber.lower().equals(normalizedWagonNumber))
      ..where((t) => t.isDeleted.equals(false))
      ..where((t) => t.status.isNotValue(WagonStatus.archived.name));
    if (excludeId != null) {
      query.where((t) => t.id.isNotValue(excludeId));
    }
    final rows = await query.get();
    return rows.isNotEmpty;
  }

  @override
  Future<void> applyItemRenames(
      String wagonId, Map<String, String> renames) async {
    final query = _db.select(_db.layers).join([
      drift.innerJoin(
        _db.trucks,
        _db.trucks.id.equalsExp(_db.layers.truckId),
      ),
    ])
      ..where(_db.trucks.wagonId.equals(wagonId) &
          _db.trucks.isDeleted.equals(false) &
          _db.layers.isDeleted.equals(false));
    final rows = await query.get();
    for (final row in rows) {
      final layer = row.readTable(_db.layers);
      try {
        final allocations =
            jsonDecode(layer.itemAllocationsJson) as List<dynamic>;
        bool changed = false;
        final newAllocations = <Map<String, dynamic>>[];
        for (final value in allocations.whereType<Map<String, dynamic>>()) {
          final itemName = (value['itemName'] as String? ?? '').trim();
          final titleName = FieldNormalizer.title(itemName);
          if (renames.containsKey(titleName)) {
            value['itemName'] = renames[titleName]!;
            changed = true;
          }
          newAllocations.add(value);
        }
        if (changed) {
          await _db.update(_db.layers).replace(
                layer.copyWith(itemAllocationsJson: jsonEncode(newAllocations)),
              );
        }
      } catch (_) {}
    }
  }

  @override
  Future<Map<String, int>> getLoadedItemQuantities(String wagonId) async {
    final query = _db.select(_db.layers).join([
      drift.innerJoin(
        _db.trucks,
        _db.trucks.id.equalsExp(_db.layers.truckId),
      ),
    ])
      ..where(_db.trucks.wagonId.equals(wagonId) &
          _db.trucks.isDeleted.equals(false) &
          _db.layers.isDeleted.equals(false));
    final rows = await query.get();
    final totals = <String, int>{};
    for (final row in rows) {
      final layer = row.readTable(_db.layers);
      var foundAllocations = false;
      try {
        final allocations =
            jsonDecode(layer.itemAllocationsJson) as List<dynamic>;
        for (final value in allocations.whereType<Map<String, dynamic>>()) {
          final itemName = (value['itemName'] as String? ?? '').trim();
          final quantity = (value['quantity'] as num? ?? 0).toInt();
          if (itemName.isEmpty || quantity <= 0) continue;
          totals[itemName] = (totals[itemName] ?? 0) + quantity;
          foundAllocations = true;
        }
      } catch (_) {
        // Use the version-5 single-item fallback below.
      }
      if (!foundAllocations) {
        final itemName = layer.itemName?.trim();
        if (itemName != null && itemName.isNotEmpty) {
          totals[itemName] = (totals[itemName] ?? 0) + layer.cartonCount;
        }
      }
    }
    return totals;
  }

  @override
  Future<void> clearAllData() async {
    await _db.delete(_db.wagons).go();
  }

  @override
  Future<void> loadDemoData({String? operatorName}) async {
    await _db.transaction(() async {
      final now = DateTime.now();
      Future<void> add({
        required String id,
        required String number,
        required WagonStatus status,
        required String origin,
        required String destination,
        required List<Map<String, Object>> items,
        required int daysAgo,
        String? remarks,
        int completedTrucks = 0,
        bool deleted = false,
      }) =>
          _db.into(_db.wagons).insert(db.WagonsCompanion.insert(
                id: id,
                wagonNumber: number,
                status: status.name,
                expectedTruckCount: 0,
                origin: drift.Value(origin),
                destination: drift.Value(destination),
                loadingDate: drift.Value(now.subtract(Duration(days: daysAgo))),
                remarks: drift.Value(remarks),
                itemManifestJson: drift.Value(jsonEncode(items)),
                completedTruckCount: drift.Value(completedTrucks),
                isDeleted: drift.Value(deleted),
                createdAt:
                    drift.Value(now.subtract(Duration(days: daysAgo + 1))),
                updatedAt: drift.Value(now.subtract(Duration(days: daysAgo))),
              ));

      await add(
          id: 'demo_wagon_planning',
          number: 'BCNHL-700184',
          status: WagonStatus.planning,
          origin: 'Guwahati ICD',
          destination: 'Kolkata Hub',
          items: const [],
          daysAgo: 0,
          remarks: 'Planning edge case: manifest not entered yet.');
      await add(
          id: 'demo_wagon_active',
          number: 'BCNHL-700219',
          status: WagonStatus.loading,
          origin: 'Guwahati ICD',
          destination: 'Pamohi Distribution Centre',
          daysAgo: 1,
          remarks: 'Priority FMCG shipment - partial and mixed-item loading.',
          items: const [
            {'name': 'Premium Rice', 'quantity': 200},
            {'name': 'Assam Tea', 'quantity': 120},
            {'name': 'Whole Spices', 'quantity': 80},
          ]);
      await add(
          id: 'demo_wagon_completed',
          number: 'BCNHL-699842',
          status: WagonStatus.completed,
          origin: 'Delhi NCR Hub',
          destination: 'Guwahati ICD',
          daysAgo: 5,
          completedTrucks: 2,
          remarks: 'Completed and fully reconciled shipment.',
          items: const [
            {'name': 'Consumer Electronics', 'quantity': 140},
            {'name': 'Home Appliances', 'quantity': 100},
          ]);
      await add(
          id: 'demo_wagon_archived',
          number: 'BCNHL-698511',
          status: WagonStatus.archived,
          origin: 'Mumbai Port',
          destination: 'Delhi NCR Hub',
          daysAgo: 30,
          completedTrucks: 1,
          remarks: 'Archived historical record with remaining inventory.',
          items: const [
            {'name': 'Auto Parts', 'quantity': 100},
            {'name': 'Lubricants', 'quantity': 50},
          ]);
      await add(
          id: 'demo_wagon_enterprise',
          number: 'BCNHL-700301',
          status: WagonStatus.loading,
          origin: 'Kolkata Mega Hub',
          destination: 'Guwahati ICD',
          daysAgo: 0,
          completedTrucks: 4,
          remarks: 'Enterprise-scale six-truck loading operation.',
          items: const [
            {'name': 'Packaged Foods', 'quantity': 1600},
            {'name': 'Personal Care', 'quantity': 1600},
            {'name': 'Household Goods', 'quantity': 1600},
          ]);
      await add(
          id: 'demo_wagon_deleted',
          number: 'DELETED-TEST-01',
          status: WagonStatus.loading,
          origin: 'Hidden',
          destination: 'Hidden',
          items: const [
            {'name': 'Hidden Item', 'quantity': 10}
          ],
          daysAgo: 10,
          deleted: true,
          remarks: 'Soft-deleted record; must not appear in lists.');
    });
  }
}
