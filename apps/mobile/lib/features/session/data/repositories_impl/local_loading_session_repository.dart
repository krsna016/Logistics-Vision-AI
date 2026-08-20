import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import '../../domain/entities/loading_session.dart';
import '../../domain/repositories/loading_session_repository.dart';
import '../../../../core/database/app_database.dart' as db;
import '../../../../utils/logger.dart';

class LocalLoadingSessionRepository implements LoadingSessionRepository {
  final db.AppDatabase _db;

  LocalLoadingSessionRepository(this._db);

  LoadingSession _map(db.LoadingSession data) {
    return LoadingSession(
      id: data.id,
      truckId: data.truckId,
      warehouseId: data.warehouseId ?? '',
      operatorId: data.operatorId,
      startTime: data.startTime,
      endTime: data.endTime,
      status: SessionStatus.values.firstWhere((e) => e.name == data.status,
          orElse: () => SessionStatus.started),
      totalLayers: data.totalLayers,
      totalCartons: data.totalCartons,
      totalDefects: data.totalDefects,
      averageConfidence: data.averageConfidence,
      modelVersion: data.modelVersion ?? '',
      notes: data.notes,
      metadata: data.metadata != null
          ? jsonDecode(data.metadata!) as Map<String, dynamic>
          : const {},
    );
  }

  @override
  Future<void> saveSession(LoadingSession session) async {
    await _db.transaction(() async {
      final exists = await (_db.select(_db.loadingSessions)
            ..where((t) => t.id.equals(session.id)))
          .getSingleOrNull();

      if (exists != null) {
        final nextVersion = exists.version + 1;
        await (_db.update(_db.loadingSessions)
              ..where((t) => t.id.equals(session.id)))
            .write(db.LoadingSessionsCompanion(
          status: drift.Value(session.status.name),
          endTime: drift.Value(session.endTime),
          totalLayers: drift.Value(session.totalLayers),
          totalCartons: drift.Value(session.totalCartons),
          totalDefects: drift.Value(session.totalDefects),
          averageConfidence: drift.Value(session.averageConfidence),
          notes: drift.Value(session.notes),
          metadata: drift.Value(jsonEncode(session.metadata)),
          version: drift.Value(nextVersion),
          updatedAt: drift.Value(DateTime.now()),
        ));
      } else {
        // Truck.warehouse is an operator-entered display value (and may be
        // "NIL"), while loading_sessions.warehouse_id is a foreign key to a
        // configured Warehouses row. Only persist the FK when that row really
        // exists; the field is nullable by design.
        final warehouseReference = session.warehouseId.trim();
        final warehouse = warehouseReference.isEmpty
            ? null
            : await (_db.select(_db.warehouses)
                  ..where((row) =>
                      row.id.equals(warehouseReference) |
                      row.name.equals(warehouseReference))
                  ..limit(1))
                .getSingleOrNull();
        await _db
            .into(_db.loadingSessions)
            .insert(db.LoadingSessionsCompanion.insert(
              id: session.id,
              truckId: session.truckId,
              warehouseId: drift.Value(warehouse?.id),
              startTime: session.startTime,
              endTime: drift.Value(session.endTime),
              operatorId: session.operatorId,
              status: session.status.name,
              totalLayers: drift.Value(session.totalLayers),
              totalCartons: drift.Value(session.totalCartons),
              totalDefects: drift.Value(session.totalDefects),
              averageConfidence: drift.Value(session.averageConfidence),
              modelVersion: drift.Value(session.modelVersion),
              notes: drift.Value(session.notes),
              metadata: drift.Value(jsonEncode(session.metadata)),
              createdAt: drift.Value(DateTime.now()),
              updatedAt: drift.Value(DateTime.now()),
            ));
      }
    });
    AppLogger.info(
        'Saved loading session: ${session.id} status=${session.status.name}');
  }

  @override
  Future<LoadingSession?> getSessionById(String id) async {
    try {
      final row = await (_db.select(_db.loadingSessions)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      return row != null ? _map(row) : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<LoadingSession?> getActiveSessionForTruck(String truckId) async {
    try {
      final query = _db.select(_db.loadingSessions)
        ..where((t) =>
            t.truckId.equals(truckId) &
            t.isDeleted.equals(false) &
            (t.status.equals(SessionStatus.started.name) |
                t.status.equals(SessionStatus.paused.name)))
        ..orderBy([
          (t) => drift.OrderingTerm(
              expression: t.updatedAt, mode: drift.OrderingMode.desc)
        ])
        ..limit(1);
      final row = await query.getSingleOrNull();
      return row != null ? _map(row) : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<LoadingSession>> getSessionsByWarehouse(
      String warehouseId) async {
    try {
      final query = _db.select(_db.loadingSessions)
        ..where((t) =>
            t.warehouseId.equals(warehouseId) & t.isDeleted.equals(false));
      final rows = await query.get();
      return rows.map(_map).toList();
    } catch (e, stack) {
      AppLogger.error('Failed reading sessions by warehouse', e, stack);
      return [];
    }
  }

  @override
  Future<LoadingSession?> recoverLastActiveSession() async {
    try {
      final query = _db.select(_db.loadingSessions)
        ..where((t) =>
            t.isDeleted.equals(false) &
            (t.status.equals(SessionStatus.started.name) |
                t.status.equals(SessionStatus.paused.name)))
        ..orderBy([
          (t) => drift.OrderingTerm(
              expression: t.updatedAt, mode: drift.OrderingMode.desc)
        ])
        ..limit(1);
      final row = await query.getSingleOrNull();
      return row != null ? _map(row) : null;
    } catch (_) {
      return null;
    }
  }
}
