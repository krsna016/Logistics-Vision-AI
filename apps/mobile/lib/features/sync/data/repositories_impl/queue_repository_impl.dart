import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/queue_repository.dart';

class QueueRepositoryImpl implements QueueRepository {
  final AppDatabase _db;

  const QueueRepositoryImpl(this._db);

  @override
  Future<void> enqueue(SyncOperation operation) async {
    await _db.into(_db.syncQueues).insert(
          SyncQueuesCompanion.insert(
            id: operation.id,
            entityId: operation.entityId,
            entityType: operation.entityType,
            operation: operation.operation.name,
            payloadData: operation.payload,
            version: Value(operation.version),
            priority: Value(operation.priority),
            status: Value(operation.status.name),
            retryCount: Value(operation.retryCount),
            createdAt: Value(operation.createdAt),
            updatedAt: Value(operation.updatedAt),
            queuedAt: Value(operation.queuedAt),
          ),
          mode: InsertMode.replace,
        );
  }

  @override
  Future<List<SyncOperation>> getPendingBatch(int batchSize) async {
    // Fetch queued items OR items that failed but are eligible for retry (status == 'failed')
    // We will let the RetryManager decide if they are actually eligible, or we just fetch everything pending
    final records = await (_db.select(_db.syncQueues)
          ..where((t) => t.status.isIn(['queued', 'failed']))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.priority, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.queuedAt, mode: OrderingMode.asc),
          ])
          ..limit(batchSize))
        .get();

    return records.map(_mapToOperation).toList();
  }

  @override
  Future<void> updateOperationStatus(String id, SyncStatus status,
      {String? errorMessage, int? retryCount}) async {
    await (_db.update(_db.syncQueues)..where((t) => t.id.equals(id))).write(
      SyncQueuesCompanion(
        status: Value(status.name),
        errorMessage:
            errorMessage != null ? Value(errorMessage) : const Value.absent(),
        retryCount:
            retryCount != null ? Value(retryCount) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<List<SyncOperation>> getAllOperations() async {
    final records = await (_db.select(_db.syncQueues)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.queuedAt, mode: OrderingMode.desc),
          ]))
        .get();

    return records.map(_mapToOperation).toList();
  }

  @override
  Future<void> pruneQueue() async {
    // Delete completed and cancelled items older than 7 days
    final threshold = DateTime.now().subtract(const Duration(days: 7));
    await (_db.delete(_db.syncQueues)
          ..where((t) =>
              t.status.isIn(['completed', 'cancelled']) &
              t.updatedAt.isSmallerThanValue(threshold)))
        .go();
  }

  SyncOperation _mapToOperation(SyncQueue r) {
    return SyncOperation(
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
    );
  }
}
