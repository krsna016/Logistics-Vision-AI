import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/queue_repository.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/services/connectivity_service.dart';
import '../../domain/services/sync_engine.dart';
import '../../domain/services/sync_worker.dart';
import '../../domain/services/retry_manager.dart';

class SyncEngineImpl implements SyncEngine {
  final ConnectivityService _connectivityService;
  final QueueRepository _queueRepo;
  final RetryManager _retryManager;
  final SyncWorker _syncWorker;

  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _retryTimer;
  bool _isRunning = false;
  bool _isProcessing = false;
  bool _hasInternet = false;

  SyncEngineImpl(
    this._connectivityService,
    this._queueRepo,
    this._retryManager,
    this._syncWorker,
  );

  @override
  Future<void> start() async {
    if (_isRunning) return;
    _isRunning = true;

    // Check initial state
    _hasInternet = await _connectivityService.hasInternetAccess();

    _connectivitySubscription =
        _connectivityService.isConnectedStream.listen((hasInternet) {
      _hasInternet = hasInternet;
      if (hasInternet) {
        debugPrint('SyncEngine: Internet restored. Resuming queue.');
        _triggerProcessing();
      }
    });

    // Prune old data on startup
    await _queueRepo.pruneQueue();

    // Auto-resume any interrupted syncs if we have internet at launch
    if (_hasInternet) {
      _triggerProcessing();
    }
  }

  @override
  Future<void> pause() async {
    _isRunning = false;
    await _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  @override
  Future<void> forceSync() async {
    if (!_hasInternet) {
      debugPrint('SyncEngine: Cannot force sync, no internet.');
      return;
    }
    _triggerProcessing();
  }

  Future<void> _triggerProcessing() async {
    if (_isProcessing || !_isRunning) return;
    _isProcessing = true;

    try {
      bool hasMore = true;
      while (hasMore && _hasInternet && _isRunning) {
        final batch = await _queueRepo.getPendingBatch(50); // Batch size 50
        if (batch.isEmpty) {
          hasMore = false;
          break;
        }
        hasMore = await _syncWorker.processBatch(batch);
      }
    } catch (e) {
      debugPrint('SyncEngine processing error: $e');
    } finally {
      _isProcessing = false;
      await _scheduleNextRetry();
    }
  }

  Future<void> _scheduleNextRetry() async {
    _retryTimer?.cancel();
    _retryTimer = null;
    if (!_isRunning || !_hasInternet) return;

    final now = DateTime.now();
    DateTime? nextRetryAt;
    for (final operation in await _queueRepo.getAllOperations()) {
      if (operation.status != SyncStatus.failed) continue;
      final eligibleAt = operation.updatedAt
          .add(_retryManager.calculateNextDelay(operation.retryCount));
      if (!eligibleAt.isAfter(now)) continue;
      if (nextRetryAt == null || eligibleAt.isBefore(nextRetryAt)) {
        nextRetryAt = eligibleAt;
      }
    }
    if (nextRetryAt == null) return;
    _retryTimer = Timer(nextRetryAt.difference(now), () {
      _triggerProcessing();
    });
  }
}
