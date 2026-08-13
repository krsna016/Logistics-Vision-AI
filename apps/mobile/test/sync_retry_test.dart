import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/features/sync/data/services/retry_manager_impl.dart';
import 'package:mobile/features/sync/data/services/sync_worker_impl.dart';
import 'package:mobile/features/sync/domain/entities/sync_operation.dart';
import 'package:mobile/features/sync/domain/repositories/queue_repository.dart';
import 'package:mobile/services/network_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

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

  test('sync merges operation metadata with the complete durable entity',
      () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.into(database.wagons).insert(WagonsCompanion.insert(
          id: 'wagon-1',
          wagonNumber: 'BCNAHS12345678901',
          status: 'planning',
          expectedTruckCount: 2,
        ));
    final operation = SyncOperation(
      id: 'wagon-update-1',
      entityType: 'Wagon',
      entityId: 'wagon-1',
      operation: SyncOperationType.update,
      payload: '{"correctionReason":"verified recount"}',
      version: 1,
      status: SyncStatus.queued,
      createdAt: DateTime(2026, 8, 13),
      updatedAt: DateTime(2026, 8, 13),
      queuedAt: DateTime(2026, 8, 13),
    );
    final queue = _InMemoryQueue([operation]);
    final network = NetworkService();
    Map<String, dynamic>? uploaded;
    network.client.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        uploaded = Map<String, dynamic>.from(options.data as Map);
        handler.resolve(Response<Map<String, dynamic>>(
          requestOptions: options,
          statusCode: 200,
          data: {
            'results': [
              {'status': 'synced', 'server_version': 1}
            ]
          },
        ));
      },
    ));

    final worker = SyncWorkerImpl(queue, RetryManagerImpl(), network, database);
    expect(await worker.attemptOperation(operation), isTrue);

    final records = uploaded!['records'] as List<dynamic>;
    final payload = (records.single as Map<String, dynamic>)['payload']
        as Map<String, dynamic>;
    expect(payload['wagonNumber'], 'BCNAHS12345678901');
    expect(payload['expectedTruckCount'], 2);
    expect(payload['correctionReason'], 'verified recount');
    expect((await database.select(database.wagons).getSingle()).syncStatus,
        'synced');
  });

  test('an old accepted operation never marks a newer local edit synced',
      () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.into(database.wagons).insert(WagonsCompanion.insert(
          id: 'wagon-newer',
          wagonNumber: 'BCNAHS12345678902',
          status: 'planning',
          expectedTruckCount: 1,
          version: const Value(2),
          syncStatus: const Value('pending'),
        ));
    final operation = SyncOperation(
      id: 'wagon-old-update',
      entityType: 'Wagon',
      entityId: 'wagon-newer',
      operation: SyncOperationType.update,
      payload: '{}',
      version: 1,
      status: SyncStatus.queued,
      createdAt: DateTime(2026, 8, 13),
      updatedAt: DateTime(2026, 8, 13),
      queuedAt: DateTime(2026, 8, 13),
    );
    final network = NetworkService();
    network.client.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) => handler.resolve(
        Response<Map<String, dynamic>>(
          requestOptions: options,
          statusCode: 200,
          data: {
            'results': [
              {'status': 'already_synced', 'server_version': 1}
            ]
          },
        ),
      ),
    ));
    final worker = SyncWorkerImpl(
        _InMemoryQueue([operation]), RetryManagerImpl(), network, database);

    expect(await worker.attemptOperation(operation), isTrue);
    final stored = await database.select(database.wagons).getSingle();
    expect(stored.version, 2);
    expect(stored.syncStatus, 'pending');
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
