import 'package:drift/drift.dart' as drift;
import '../../domain/entities/wagon.dart';
import '../../domain/repositories/wagon_repository.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../../../utils/logger.dart';

class LocalWagonRepository implements WagonRepository {
  final db.AppDatabase _db;

  LocalWagonRepository(this._db);

  Wagon _map(db.Wagon data) {
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
            completedTruckCount: drift.Value(wagon.completedTruckCount),
            createdAt: drift.Value(wagon.createdAt),
            updatedAt: drift.Value(wagon.updatedAt),
          ));

      await _db.into(_db.syncQueues).insert(db.SyncQueuesCompanion.insert(
            id: 'sync_w_${DateTime.now().millisecondsSinceEpoch}',
            entityId: wagon.id,
            entityType: 'Wagon',
            operation: 'INSERT',
            payloadData: '{}',
          ));
    });
    AppLogger.info('Created new wagon record locally: ${wagon.wagonNumber}');
  }

  @override
  Future<void> updateWagon(Wagon wagon) async {
    await _db.transaction(() async {
      await (_db.update(_db.wagons)..where((t) => t.id.equals(wagon.id)))
          .write(db.WagonsCompanion(
        wagonNumber: drift.Value(wagon.wagonNumber),
        status: drift.Value(wagon.status.name),
        expectedTruckCount: drift.Value(wagon.expectedTruckCount),
        origin: drift.Value(wagon.origin),
        destination: drift.Value(wagon.destination),
        loadingDate: drift.Value(wagon.loadingDate),
        remarks: drift.Value(wagon.remarks),
        completedTruckCount: drift.Value(wagon.completedTruckCount),
        updatedAt: drift.Value(DateTime.now()),
      ));

      await _db.into(_db.syncQueues).insert(db.SyncQueuesCompanion.insert(
            id: 'sync_w_${DateTime.now().millisecondsSinceEpoch}',
            entityId: wagon.id,
            entityType: 'Wagon',
            operation: 'UPDATE',
            payloadData: '{}',
          ));
    });
    AppLogger.info('Updated wagon record: ${wagon.wagonNumber}');
  }

  @override
  Future<void> deleteWagon(String id) async {
    await _db.transaction(() async {
      await (_db.update(_db.wagons)..where((t) => t.id.equals(id))).write(
          db.WagonsCompanion(
              isDeleted: const drift.Value(true),
              updatedAt: drift.Value(DateTime.now())) // soft delete
          );

      await _db.into(_db.syncQueues).insert(db.SyncQueuesCompanion.insert(
            id: 'sync_w_${DateTime.now().millisecondsSinceEpoch}',
            entityId: id,
            entityType: 'Wagon',
            operation: 'DELETE',
            payloadData: '{}',
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
  Future<void> clearAllData() async {
    await _db.delete(_db.wagons).go();
  }

  @override
  Future<void> loadDemoData() async {
    await _db.transaction(() async {
      final now = DateTime(2026, 7, 21, 18, 0);
      await _db.into(_db.wagons).insert(db.WagonsCompanion.insert(
            id: 'sheet_wagon_10866',
            wagonNumber: '10866',
            status: WagonStatus.loading.name,
            expectedTruckCount: 5,
            origin: const drift.Value('CGS'),
            destination: const drift.Value('PAMOHI'),
            loadingDate: drift.Value(now),
            remarks: const drift.Value('Sheet-style loading register demo'),
            completedTruckCount: const drift.Value(0),
            createdAt: drift.Value(now.subtract(const Duration(hours: 8))),
            updatedAt: drift.Value(now.subtract(const Duration(minutes: 20))),
          ));
    });
  }
}
