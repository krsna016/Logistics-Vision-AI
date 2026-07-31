import 'dart:convert';
import '../../domain/entities/sync_operation.dart';
import '../../domain/services/conflict_resolver.dart';

class ConflictResolverImpl implements ConflictResolver {
  /// Resolves conflict by returning the payload of the newest version based on timestamp.
  /// If timestamps are unavailable, defaults to Local Wins.
  @override
  Future<String> resolveConflict(
      SyncOperation localOp, String remotePayload) async {
    try {
      final localMap = jsonDecode(localOp.payload) as Map<String, dynamic>;
      final remoteMap = jsonDecode(remotePayload) as Map<String, dynamic>;

      final localUpdatedAt =
          _parseDate(localMap['updatedAt']) ?? localOp.updatedAt;
      final remoteUpdatedAt = _parseDate(remoteMap['updatedAt']);

      if (remoteUpdatedAt == null) return localOp.payload;

      // Newest Version Wins
      if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
        return localOp.payload;
      } else {
        return remotePayload;
      }
    } catch (e) {
      // Fallback: Local Wins
      return localOp.payload;
    }
  }

  DateTime? _parseDate(dynamic dateValue) {
    if (dateValue == null) return null;
    if (dateValue is String) {
      return DateTime.tryParse(dateValue);
    }
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    return null;
  }
}
