import '../entities/sync_operation.dart';

abstract class SyncWorker {
  /// Processes a single batch of operations. Returns true if more batches exist.
  Future<bool> processBatch(List<SyncOperation> operations);

  /// Attempts a single operation against the remote server.
  Future<bool> attemptOperation(SyncOperation operation);
}
