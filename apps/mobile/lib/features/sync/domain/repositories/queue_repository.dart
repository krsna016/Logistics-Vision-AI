import '../entities/sync_operation.dart';

abstract class QueueRepository {
  /// Enqueues a new operation to be synced.
  Future<void> enqueue(SyncOperation operation);

  /// Retrieves the next batch of pending operations.
  Future<List<SyncOperation>> getPendingBatch(int batchSize);

  /// Updates the status of an operation (e.g., syncing, completed, failed).
  Future<void> updateOperationStatus(String id, SyncStatus status, {String? errorMessage, int? retryCount});

  /// Retrieves all items currently in the queue, regardless of status.
  Future<List<SyncOperation>> getAllOperations();

  /// Clears completed or cancelled operations from the queue to save space.
  Future<void> pruneQueue();
}
