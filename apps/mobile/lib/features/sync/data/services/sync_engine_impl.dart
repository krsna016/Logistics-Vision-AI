import 'dart:async';
import '../../../../utils/logger.dart';
import '../../domain/services/sync_engine.dart';
import '../../domain/repositories/queue_repository.dart';
import '../../domain/services/connectivity_service.dart';
import 'retry_manager_impl.dart';
import '../../domain/services/sync_worker.dart';

class SyncEngineImpl implements SyncEngine {
  SyncEngineImpl(
    ConnectivityService connectivityService,
    QueueRepository queueRepo,
    RetryManager retryManager,
    SyncWorker syncWorker,
  );

  @override
  Future<void> start() async {
    AppLogger.info('SyncEngine: Central Data Sync has been fully disabled per user configuration.');
  }

  @override
  void pause() {
    // Disabled
  }

  @override
  Future<void> triggerManualSync() async {
    AppLogger.info('SyncEngine: Manual sync ignored. Central Data Sync is fully disabled.');
  }
}
