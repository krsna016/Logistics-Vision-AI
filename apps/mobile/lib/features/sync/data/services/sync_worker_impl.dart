import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
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

  SyncWorkerImpl(this._queueRepo, this._retryManager, NetworkService network, this._db)
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

      if (success) {
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

    // Check if there are more pending in the db
    final remaining = await _queueRepo.getPendingBatch(1);
    return remaining.isNotEmpty;
  }

  @override
  Future<bool> attemptOperation(SyncOperation operation) async {
    try {
      final decoded = jsonDecode(operation.payload);
      var payload = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
      if (payload.isEmpty) payload = await _readCurrentPayload(operation);
      final response = await _dio.post<Map<String, dynamic>>('/sync/batch', data: {
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
      return status == 'synced' || status == 'already_synced';
    } on DioException catch (error) {
      debugPrint('Sync upload failed for ${operation.entityId}: ${error.message}');
      return false;
    } on FormatException {
      debugPrint('Sync payload is not valid JSON for ${operation.entityId}');
      return false;
    }
  }

  Future<Map<String, dynamic>> _readCurrentPayload(SyncOperation operation) async {
    switch (operation.entityType) {
      case 'Wagon':
        final row = await (_db.select(_db.wagons)..where((t) => t.id.equals(operation.entityId))).getSingleOrNull();
        if (row == null) return {};
        return {'id': row.id, 'wagonNumber': row.wagonNumber, 'status': row.status,
          'warehouseId': row.warehouseId, 'origin': row.origin, 'destination': row.destination,
          'loadingDate': row.loadingDate?.toUtc().toIso8601String(), 'remarks': row.remarks,
          'expectedTruckCount': row.expectedTruckCount, 'completedTruckCount': row.completedTruckCount,
          'itemManifestJson': row.itemManifestJson, 'createdAt': row.createdAt.toUtc().toIso8601String(),
          'updatedAt': row.updatedAt.toUtc().toIso8601String(), 'isDeleted': row.isDeleted};
      case 'Truck':
        final row = await (_db.select(_db.trucks)..where((t) => t.id.equals(operation.entityId))).getSingleOrNull();
        if (row == null) return {};
        return {'id': row.id, 'wagonId': row.wagonId, 'truckNumber': row.truckNumber,
          'vehicleNumber': row.vehicleNumber, 'driverName': row.driverName, 'driverMobile': row.driverMobile,
          'company': row.company, 'warehouse': row.warehouse, 'status': row.status,
          'completedDate': row.completedDate?.toUtc().toIso8601String(), 'notes': row.notes,
          'totalLayers': row.totalLayers, 'totalCartons': row.totalCartons, 'totalDefects': row.totalDefects,
          'isArchived': row.isArchived, 'createdAt': row.createdAt.toUtc().toIso8601String(),
          'updatedAt': row.updatedAt.toUtc().toIso8601String(), 'isDeleted': row.isDeleted};
      case 'Layer':
        final row = await (_db.select(_db.layers)..where((t) => t.id.equals(operation.entityId))).getSingleOrNull();
        if (row == null) return {};
        return {'id': row.id, 'truckId': row.truckId, 'layerNumber': row.layerNumber,
          'cartonCount': row.cartonCount, 'defectCount': row.defectCount, 'photoPath': row.photoPath,
          'notes': row.notes, 'itemName': row.itemName, 'itemAllocationsJson': row.itemAllocationsJson,
          'averageConfidence': row.averageConfidence, 'timestamp': row.timestamp?.toUtc().toIso8601String(),
          'operatorId': row.operatorId, 'modelVersion': row.modelVersion,
          'createdAt': row.createdAt.toUtc().toIso8601String(), 'updatedAt': row.updatedAt.toUtc().toIso8601String(),
          'isDeleted': row.isDeleted};
      default:
        return {};
    }
  }
}
