import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/queue_repository.dart';
import '../../domain/services/conflict_resolver.dart';
import '../../domain/services/retry_manager.dart';
import '../../domain/services/sync_worker.dart';

class SyncWorkerImpl implements SyncWorker {
  final QueueRepository _queueRepo;
  final RetryManager _retryManager;
  final ConflictResolver _conflictResolver;

  const SyncWorkerImpl(this._queueRepo, this._retryManager, this._conflictResolver);

  @override
  Future<bool> processBatch(List<SyncOperation> operations) async {
    bool hasMore = false;
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
          await _queueRepo.updateOperationStatus(op.id, SyncStatus.failed, retryCount: newRetryCount, errorMessage: 'Network/API timeout');
        } else {
          // If we hit max retries without a network recovery, we can flag as conflict or permanently failed
          await _queueRepo.updateOperationStatus(op.id, SyncStatus.conflict, retryCount: newRetryCount, errorMessage: 'Max retries exceeded');
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
      // Simulate fake backend API latency for the sake of the engine test
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Simulate random network failure (10% chance) to trigger RetryManager logic
      if (DateTime.now().millisecond % 10 == 0) {
        throw Exception('Simulated network drop');
      }
      
      return true; // Success!
    } catch (e) {
      debugPrint('SyncWorker error: $e');
      return false;
    }
  }
}
