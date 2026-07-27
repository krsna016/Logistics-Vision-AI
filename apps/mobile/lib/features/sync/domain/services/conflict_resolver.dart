import '../entities/sync_operation.dart';

abstract class ConflictResolver {
  /// Resolves a conflict between a local operation and a remote server state.
  /// Returns the winning payload or state.
  Future<String> resolveConflict(SyncOperation localOp, String remotePayload);
}
