import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/providers/database_provider.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/queue_repository.dart';
import '../../domain/services/connectivity_service.dart';
import '../../domain/services/sync_engine.dart';

import '../../data/repositories_impl/queue_repository_impl.dart';
import '../../data/services/connectivity_service_impl.dart';
import '../../data/services/retry_manager_impl.dart';
import '../../data/services/conflict_resolver_impl.dart';
import '../../data/services/sync_worker_impl.dart';
import '../../data/services/sync_engine_impl.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityServiceImpl(Connectivity());
});

final queueRepositoryProvider = Provider<QueueRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return QueueRepositoryImpl(db);
});

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final connService = ref.watch(connectivityServiceProvider);
  final queueRepo = ref.watch(queueRepositoryProvider);

  final retryManager = RetryManagerImpl();
  final conflictResolver = ConflictResolverImpl();
  final worker = SyncWorkerImpl(queueRepo, retryManager, conflictResolver);

  final engine = SyncEngineImpl(connService, queueRepo, worker);

  // Auto-start the engine when instantiated
  engine.start();

  ref.onDispose(() {
    engine.pause();
  });

  return engine;
});

// UI State Providers
final syncQueueStreamProvider =
    StreamProvider<List<SyncOperation>>((ref) async* {
  // Drift doesn't support streams on raw custom queries easily, so we can poll every 2 seconds for UI updates
  // Or since we just want to watch the table:
  final db = ref.watch(databaseProvider);
  yield* db.select(db.syncQueues).watch().map((rows) {
    return rows
        .map((r) => SyncOperation(
              id: r.id,
              entityType: r.entityType,
              entityId: r.entityId,
              operation: SyncOperationType.values.firstWhere(
                  (e) => e.name == r.operation,
                  orElse: () => SyncOperationType.insert),
              payload: r.payloadData,
              version: r.version,
              priority: r.priority,
              status: SyncStatus.values.firstWhere((e) => e.name == r.status,
                  orElse: () => SyncStatus.queued),
              retryCount: r.retryCount,
              errorMessage: r.errorMessage,
              createdAt: r.createdAt,
              updatedAt: r.updatedAt,
              queuedAt: r.queuedAt,
            ))
        .toList();
  });
});
