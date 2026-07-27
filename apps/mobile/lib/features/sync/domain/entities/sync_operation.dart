class SyncOperation {
  final String id;
  final String entityType;
  final String entityId;
  final SyncOperationType operation;
  final String payload;
  final int version;
  final int priority;
  final SyncStatus status;
  final int retryCount;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime queuedAt;

  const SyncOperation({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    this.version = 1,
    this.priority = 0,
    required this.status,
    this.retryCount = 0,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
    required this.queuedAt,
  });

  SyncOperation copyWith({
    String? id,
    String? entityType,
    String? entityId,
    SyncOperationType? operation,
    String? payload,
    int? version,
    int? priority,
    SyncStatus? status,
    int? retryCount,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? queuedAt,
  }) {
    return SyncOperation(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      version: version ?? this.version,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      queuedAt: queuedAt ?? this.queuedAt,
    );
  }
}

enum SyncOperationType {
  insert,
  update,
  delete,
  archive,
  restore
}

enum SyncStatus {
  queued('Queued', 'In Queue'),
  syncing('Syncing', 'Transferring...'),
  completed('Completed', 'Synced'),
  conflict('Conflict', 'Needs Review'),
  failed('Failed', 'Retrying...'),
  cancelled('Cancelled', 'Sync Cancelled');

  final String label;
  final String subtext;
  const SyncStatus(this.label, this.subtext);
}
