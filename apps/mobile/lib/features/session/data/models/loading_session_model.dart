import '../../domain/entities/loading_session.dart';

class LoadingSessionModel {
  static LoadingSession fromJson(Map<String, dynamic> json) {
    return LoadingSession(
      id: json['id'] as String,
      truckId: json['truckId'] as String,
      warehouseId: json['warehouseId'] as String,
      operatorId: json['operatorId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      status: SessionStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String),
        orElse: () => SessionStatus.created,
      ),
      totalLayers: json['totalLayers'] as int? ?? 0,
      totalCartons: json['totalCartons'] as int? ?? 0,
      totalDefects: json['totalDefects'] as int? ?? 0,
      averageConfidence: (json['averageConfidence'] as num? ?? 0.0).toDouble(),
      modelVersion:
          json['modelVersion'] as String? ?? 'yolo11n_carton_seg_v1_3',
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }

  static Map<String, dynamic> toJson(LoadingSession session) {
    return {
      'id': session.id,
      'truckId': session.truckId,
      'warehouseId': session.warehouseId,
      'operatorId': session.operatorId,
      'startTime': session.startTime.toIso8601String(),
      'endTime': session.endTime?.toIso8601String(),
      'status': session.status.name,
      'totalLayers': session.totalLayers,
      'totalCartons': session.totalCartons,
      'totalDefects': session.totalDefects,
      'averageConfidence': session.averageConfidence,
      'modelVersion': session.modelVersion,
      'notes': session.notes,
      'metadata': session.metadata,
    };
  }
}
