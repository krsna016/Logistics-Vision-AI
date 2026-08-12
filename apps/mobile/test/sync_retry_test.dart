import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/features/sync/data/services/retry_manager_impl.dart';
import 'package:mobile/features/sync/data/services/sync_worker_impl.dart';
import 'package:mobile/features/sync/domain/entities/sync_operation.dart';
import 'package:mobile/features/sync/domain/repositories/queue_repository.dart';
import 'package:mobile/services/network_service.dart';

void main() {
  test('a backoff-delayed failure does not keep the sync engine busy',
      () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final operation = SyncOperation(
      id: 'delayed-operation',
      entityType: 'Layer',
      entityId: 'layer-1',
      operation: SyncOperationType.update,
      payload: '{}',
      status: SyncStatus.failed,
      retryCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      queuedAt: DateTime.now(),
    );
    final queue = _InMemoryQueue([operation]);
    final worker = SyncWorkerImpl(
      queue,
      RetryManagerImpl(),
      NetworkService(),
      database,
    );

    expect(await worker.processBatch([operation]), isFalse);
    expect(queue.updatedStatuses, isEmpty);
  });
}

class _InMemoryQueue implements QueueRepository {
  final List<SyncOperation> operations;
  final List<SyncStatus> updatedStatuses = [];

  _InMemoryQueue(this.operations);

  @override
  Future<void> enqueue(SyncOperation operation) async {
    operations.add(operation);
  }

  @override
  Future<List<SyncOperation>> getAllOperations() async => operations;

  @override
  Future<List<SyncOperation>> getPendingBatch(int batchSize) async => operations
      .where((operation) =>
          operation.status == SyncStatus.queued ||
          operation.status == SyncStatus.failed)
      .take(batchSize)
      .toList(growable: false);

  @override
  Future<void> pruneQueue() async {}

  @override
  Future<void> updateOperationStatus(
    String id,
    SyncStatus status, {
    String? errorMessage,
    int? retryCount,
  }) async {
    updatedStatuses.add(status);
  }
}
