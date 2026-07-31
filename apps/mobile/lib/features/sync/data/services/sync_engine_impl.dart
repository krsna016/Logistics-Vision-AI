import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/queue_repository.dart';
import '../../domain/services/connectivity_service.dart';
import '../../domain/services/sync_engine.dart';
import '../../domain/services/sync_worker.dart';

class SyncEngineImpl implements SyncEngine {
  final ConnectivityService _connectivityService;
  final QueueRepository _queueRepo;
  final SyncWorker _syncWorker;

  StreamSubscription<bool>? _connectivitySubscription;
  bool _isRunning = false;
  bool _isProcessing = false;
  bool _hasInternet = false;

  SyncEngineImpl(this._connectivityService, this._queueRepo, this._syncWorker);

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
    }
  }
}
