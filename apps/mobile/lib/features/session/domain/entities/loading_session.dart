import 'package:flutter/foundation.dart';
import '../../../truck/domain/entities/truck.dart';

enum SessionStatus {
  created,
  started,
  paused,
  completed,
  cancelled,
  archived;

  String get displayName {
    switch (this) {
      case SessionStatus.created:
        return 'Created';
      case SessionStatus.started:
        return 'Active Loading';
      case SessionStatus.paused:
        return 'Paused';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.cancelled:
        return 'Cancelled';
      case SessionStatus.archived:
        return 'Archived';
    }
  }
}

@immutable
class LoadingSession {
  final String id;
  final String truckId;
  final String warehouseId;
  final String operatorId;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionStatus status;
  final int totalLayers;
  final int totalCartons;
  final int totalDefects;
  final double averageConfidence;
  final String modelVersion;
  final String? notes;
  final SyncStatus syncStatus;
  final Map<String, dynamic> metadata;

  const LoadingSession({
    required this.id,
    required this.truckId,
    required this.warehouseId,
    required this.operatorId,
    required this.startTime,
    this.endTime,
    required this.status,
    this.totalLayers = 0,
    this.totalCartons = 0,
    this.totalDefects = 0,
    this.averageConfidence = 0.0,
    required this.modelVersion,
    this.notes,
    this.syncStatus = SyncStatus.pending,
    this.metadata = const {},
  });

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  LoadingSession copyWith({
    String? id,
    String? truckId,
    String? warehouseId,
    String? operatorId,
    DateTime? startTime,
    DateTime? endTime,
    SessionStatus? status,
    int? totalLayers,
    int? totalCartons,
    int? totalDefects,
    double? averageConfidence,
    String? modelVersion,
    String? notes,
    SyncStatus? syncStatus,
    Map<String, dynamic>? metadata,
  }) {
    return LoadingSession(
      id: id ?? this.id,
      truckId: truckId ?? this.truckId,
      warehouseId: warehouseId ?? this.warehouseId,
      operatorId: operatorId ?? this.operatorId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      totalLayers: totalLayers ?? this.totalLayers,
      totalCartons: totalCartons ?? this.totalCartons,
      totalDefects: totalDefects ?? this.totalDefects,
      averageConfidence: averageConfidence ?? this.averageConfidence,
      modelVersion: modelVersion ?? this.modelVersion,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
      metadata: metadata ?? this.metadata,
    );
  }
}
