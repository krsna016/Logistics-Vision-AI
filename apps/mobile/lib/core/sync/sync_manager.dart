import 'dart:async';
import 'package:logger/logger.dart';
import '../database/app_database.dart';
import 'connectivity_service.dart';
import 'package:drift/drift.dart';

class SyncManager {
  final AppDatabase _db;
  final ConnectivityService _connectivityService;
  final Logger _logger = Logger();
  StreamSubscription<bool>? _connectionSub;
  bool _isSyncing = false;

  SyncManager(this._db, this._connectivityService) {
    _init();
  }

  void _init() {
    _connectionSub =
        _connectivityService.onConnectionChange.listen((isConnected) {
      if (isConnected) {
        _logger.i('Network restored. Starting sync...');
        triggerSync();
      }
    });
  }

  Future<void> triggerSync() async {
    if (_isSyncing) return;
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) return;

    _isSyncing = true;
    try {
      await _processSyncQueue();
    } catch (e) {
      _logger.e('Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _processSyncQueue() async {
    // Get all pending or failed items (with retry limits)
    final pendingItems = await (_db.select(_db.syncQueues)
          ..where((q) => q.status.equals('pending') | q.status.equals('failed'))
          ..where((q) => q.retryCount.isSmallerThanValue(5))
          ..orderBy([
            (q) => OrderingTerm(expression: q.queuedAt, mode: OrderingMode.asc)
          ]))
        .get();

    if (pendingItems.isEmpty) return;

    _logger.i('Found ${pendingItems.length} items to sync.');

    for (final item in pendingItems) {
      if (!await _connectivityService.isConnected()) {
        _logger.w('Connection lost during sync. Pausing.');
        break;
      }

      // Mark as syncing
      await (_db.update(_db.syncQueues)..where((q) => q.id.equals(item.id)))
          .write(const SyncQueuesCompanion(status: Value('syncing')));

      try {
        // Simulate Future Cloud API Call
        await _simulateCloudSync(item);

        // On Success, mark as synced or delete from queue
        // We will just mark as synced for audit history or delete them. Let's delete to keep queue small.
        await (_db.delete(_db.syncQueues)..where((q) => q.id.equals(item.id)))
            .go();

        // Also update the local record's syncStatus to 'synced'
        await _updateEntitySyncStatus(item.entityType, item.entityId, 'synced');
      } catch (e) {
        _logger.e('Failed to sync item ${item.id}: $e');

        // Handle Conflict Resolution Hooks here
        if (e.toString().contains('conflict')) {
          await _handleConflict(item);
        } else {
          // Increment retry count and mark failed
          await (_db.update(_db.syncQueues)..where((q) => q.id.equals(item.id)))
              .write(
            SyncQueuesCompanion(
              status: const Value('failed'),
              retryCount: Value(item.retryCount + 1),
              errorMessage: Value(e.toString()),
            ),
          );
        }
      }
    }
  }

  Future<void> _simulateCloudSync(SyncQueue item) async {
    // In the future, parse item.payloadData and push to Supabase/REST
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate latency
  }

  Future<void> _updateEntitySyncStatus(
      String entityType, String entityId, String status) async {
    // Dynamic update based on entity type.
    // Example:
    switch (entityType) {
      case 'Wagon':
        await (_db.update(_db.wagons)..where((t) => t.id.equals(entityId)))
            .write(WagonsCompanion(syncStatus: Value(status)));
        break;
      case 'Truck':
        await (_db.update(_db.trucks)..where((t) => t.id.equals(entityId)))
            .write(TrucksCompanion(syncStatus: Value(status)));
        break;
      case 'Layer':
        await (_db.update(_db.layers)..where((t) => t.id.equals(entityId)))
            .write(LayersCompanion(syncStatus: Value(status)));
        break;
    }
  }

  Future<void> _handleConflict(SyncQueue item) async {
    // Future server conflict policies (Duplicate updates, Version mismatch, Clock differences)
    // Mark the queue item as conflict
    await (_db.update(_db.syncQueues)..where((q) => q.id.equals(item.id)))
        .write(
      const SyncQueuesCompanion(
          status: Value('conflict'),
          errorMessage: Value('Version mismatch conflict')),
    );
    await _updateEntitySyncStatus(item.entityType, item.entityId, 'conflict');
  }

  void dispose() {
    _connectionSub?.cancel();
  }
}
