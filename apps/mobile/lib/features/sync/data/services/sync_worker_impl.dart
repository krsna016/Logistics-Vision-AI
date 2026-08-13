import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/queue_repository.dart';
import '../../domain/services/retry_manager.dart';
import '../../domain/services/sync_worker.dart';
import '../../../../services/network_service.dart';
import '../../../../core/database/app_database.dart';

class SyncWorkerImpl implements SyncWorker {
  final QueueRepository _queueRepo;
  final RetryManager _retryManager;
  final Dio _dio;
  final AppDatabase _db;
  bool _lastConflict = false;

  SyncWorkerImpl(
      this._queueRepo, this._retryManager, NetworkService network, this._db)
      : _dio = network.client;

  @override
  Future<bool> processBatch(List<SyncOperation> operations) async {
    for (var op in operations) {
      // Before attempting, check if it's failed and needs to wait for backoff
      if (op.status == SyncStatus.failed) {
        final nextRetryDelay = _retryManager.calculateNextDelay(op.retryCount);
        final eligibleTime = op.updatedAt.add(nextRetryDelay);
        if (DateTime.now().isBefore(eligibleTime)) {
          continue; // Skip this one for now, backoff hasn't expired
        }
      }

      await _queueRepo.updateOperationStatus(op.id, SyncStatus.syncing);

      final success = await attemptOperation(op);

      if (_lastConflict) {
        _lastConflict = false;
        continue;
      } else if (success) {
        await _queueRepo.updateOperationStatus(op.id, SyncStatus.completed);
      } else {
        final newRetryCount = op.retryCount + 1;
        if (_retryManager.shouldRetry(newRetryCount)) {
          await _queueRepo.updateOperationStatus(op.id, SyncStatus.failed,
              retryCount: newRetryCount, errorMessage: 'Network/API timeout');
        } else {
          // If we hit max retries without a network recovery, we can flag as conflict or permanently failed
          await _queueRepo.updateOperationStatus(op.id, SyncStatus.conflict,
              retryCount: newRetryCount, errorMessage: 'Max retries exceeded');
        }
      }
    }

    // A failed record that is still in its retry window is pending, but it is
    // not work that can be processed now. Reporting it as available made the
    // engine immediately fetch the same batch again in a tight loop.
    final remaining = await _queueRepo.getPendingBatch(50);
    final now = DateTime.now();
    return remaining.any((operation) {
      if (operation.status != SyncStatus.failed) return true;
      final eligibleAt = operation.updatedAt
          .add(_retryManager.calculateNextDelay(operation.retryCount));
      return !now.isBefore(eligibleAt);
    });
  }

  @override
  Future<bool> attemptOperation(SyncOperation operation) async {
    try {
      final decoded = jsonDecode(operation.payload);
      final operationMetadata =
          decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      // Queue payloads may contain only operation metadata (for example a
      // correction reason). Always merge that with the current durable row;
      // otherwise the server envelope is replaced by an incomplete fragment.
      final payload = <String, dynamic>{
        ...await _readCurrentPayload(operation),
        ...operationMetadata,
      };
      final response =
          await _dio.post<Map<String, dynamic>>('/sync/batch', data: {
        'records': [
          {
            'operation_id': operation.id,
            'entity_type': operation.entityType,
            'entity_id': operation.entityId,
            'operation': operation.operation.name.toUpperCase(),
            'payload': payload,
            'version': operation.version,
            'created_at': operation.createdAt.toUtc().toIso8601String(),
            'updated_at': operation.updatedAt.toUtc().toIso8601String(),
          }
        ],
      });
      final results = response.data?['results'];
      if (results is! List || results.isEmpty) return false;
      final status = (results.first as Map<String, dynamic>)['status'];
      final serverVersion =
          (results.first as Map<String, dynamic>)['server_version'];
      if (status == 'conflict') {
        _lastConflict = true;
        await _queueRepo.updateOperationStatus(
          operation.id,
          SyncStatus.conflict,
          errorMessage:
              'Server has a newer version; administrator review required.',
        );
        return false;
      }
      final accepted = status == 'synced' || status == 'already_synced';
      if (accepted && serverVersion is int) {
        await _markEntitySynced(operation, serverVersion);
      }
      return accepted;
    } on DioException catch (error) {
      debugPrint(
          'Sync upload failed for ${operation.entityId}: ${error.message}');
      return false;
    } on FormatException {
      debugPrint('Sync payload is not valid JSON for ${operation.entityId}');
      return false;
    }
  }

  Future<void> _markEntitySynced(
      SyncOperation operation, int serverVersion) async {
    // An older queued operation can complete after the entity was edited
    // again. Never lower its version or mark those newer local changes synced.
    switch (operation.entityType) {
      case 'Wagon':
        final row = await (_db.select(_db.wagons)
              ..where((item) => item.id.equals(operation.entityId)))
            .getSingleOrNull();
        if (row != null && row.version <= serverVersion) {
          await (_db.update(_db.wagons)
                ..where((item) => item.id.equals(operation.entityId)))
              .write(WagonsCompanion(
            version: Value(serverVersion),
            syncStatus: const Value('synced'),
          ));
        }
        return;
      case 'Truck':
        final row = await (_db.select(_db.trucks)
              ..where((item) => item.id.equals(operation.entityId)))
            .getSingleOrNull();
        if (row != null && row.version <= serverVersion) {
          await (_db.update(_db.trucks)
                ..where((item) => item.id.equals(operation.entityId)))
              .write(TrucksCompanion(
            version: Value(serverVersion),
            syncStatus: const Value('synced'),
          ));
        }
        return;
      case 'Layer':
        final row = await (_db.select(_db.layers)
              ..where((item) => item.id.equals(operation.entityId)))
            .getSingleOrNull();
        if (row != null && row.version <= serverVersion) {
          await (_db.update(_db.layers)
                ..where((item) => item.id.equals(operation.entityId)))
              .write(LayersCompanion(
            version: Value(serverVersion),
            syncStatus: const Value('synced'),
          ));
        }
        return;
      case 'LoadingSession':
        final row = await (_db.select(_db.loadingSessions)
              ..where((item) => item.id.equals(operation.entityId)))
            .getSingleOrNull();
        if (row != null && row.version <= serverVersion) {
          await (_db.update(_db.loadingSessions)
                ..where((item) => item.id.equals(operation.entityId)))
              .write(LoadingSessionsCompanion(
            version: Value(serverVersion),
            syncStatus: const Value('synced'),
          ));
        }
        return;
      default:
        return;
    }
  }

  Future<Map<String, dynamic>> _readCurrentPayload(
      SyncOperation operation) async {
    switch (operation.entityType) {
      case 'Wagon':
        final row = await (_db.select(_db.wagons)
              ..where((t) => t.id.equals(operation.entityId)))
            .getSingleOrNull();
        if (row == null) return {};
        return {
          'id': row.id,
          'wagonNumber': row.wagonNumber,
          'status': row.status,
          'warehouseId': row.warehouseId,
          'origin': row.origin,
          'destination': row.destination,
          'loadingDate': row.loadingDate?.toUtc().toIso8601String(),
          'remarks': row.remarks,
          'expectedTruckCount': row.expectedTruckCount,
          'completedTruckCount': row.completedTruckCount,
          'itemManifestJson': row.itemManifestJson,
          'createdAt': row.createdAt.toUtc().toIso8601String(),
          'updatedAt': row.updatedAt.toUtc().toIso8601String(),
          'isDeleted': row.isDeleted
        };
      case 'Truck':
        final row = await (_db.select(_db.trucks)
              ..where((t) => t.id.equals(operation.entityId)))
            .getSingleOrNull();
        if (row == null) return {};
        return {
          'id': row.id,
          'wagonId': row.wagonId,
          'truckNumber': row.truckNumber,
          'vehicleNumber': row.vehicleNumber,
          'driverName': row.driverName,
          'driverMobile': row.driverMobile,
          'company': row.company,
          'warehouse': row.warehouse,
          'status': row.status,
          'completedDate': row.completedDate?.toUtc().toIso8601String(),
          'notes': row.notes,
          'totalLayers': row.totalLayers,
          'totalCartons': row.totalCartons,
          'totalDefects': row.totalDefects,
          'isArchived': row.isArchived,
          'createdAt': row.createdAt.toUtc().toIso8601String(),
          'updatedAt': row.updatedAt.toUtc().toIso8601String(),
          'isDeleted': row.isDeleted
        };
      case 'Layer':
        final row = await (_db.select(_db.layers)
              ..where((t) => t.id.equals(operation.entityId)))
            .getSingleOrNull();
        if (row == null) return {};
        return {
          'id': row.id,
          'truckId': row.truckId,
          'layerNumber': row.layerNumber,
          'cartonCount': row.cartonCount,
          'defectCount': row.defectCount,
          'photoPath': row.photoPath,
          'notes': row.notes,
          'itemName': row.itemName,
          'itemAllocationsJson': row.itemAllocationsJson,
          'averageConfidence': row.averageConfidence,
          'timestamp': row.timestamp?.toUtc().toIso8601String(),
          'operatorId': row.operatorId,
          'modelVersion': row.modelVersion,
          'createdAt': row.createdAt.toUtc().toIso8601String(),
          'updatedAt': row.updatedAt.toUtc().toIso8601String(),
          'isDeleted': row.isDeleted
        };
      case 'LoadingSession':
        final row = await (_db.select(_db.loadingSessions)
              ..where((t) => t.id.equals(operation.entityId)))
            .getSingleOrNull();
        if (row == null) return {};
        return {
          'id': row.id,
          'truckId': row.truckId,
          'warehouseId': row.warehouseId,
          'operatorId': row.operatorId,
          'startTime': row.startTime.toUtc().toIso8601String(),
          'endTime': row.endTime?.toUtc().toIso8601String(),
          'status': row.status,
          'totalLayers': row.totalLayers,
          'totalCartons': row.totalCartons,
          'totalDefects': row.totalDefects,
          'averageConfidence': row.averageConfidence,
          'modelVersion': row.modelVersion,
          'notes': row.notes,
          'metadata': row.metadata,
          'createdAt': row.createdAt.toUtc().toIso8601String(),
          'updatedAt': row.updatedAt.toUtc().toIso8601String(),
          'isDeleted': row.isDeleted,
        };
      default:
        return {};
    }
  }
}
