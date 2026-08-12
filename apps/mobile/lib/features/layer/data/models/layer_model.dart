import '../../domain/entities/layer.dart';
import '../../../truck/domain/entities/truck.dart';

class LayerModel {
  static LayerRecord fromJson(Map<String, dynamic> json) {
    return LayerRecord(
      id: json['id'] as String,
      truckId: json['truckId'] as String,
      layerNumber: json['layerNumber'] as int,
      cartonCount: json['cartonCount'] as int,
      defectCount: json['defectCount'] as int? ?? 0,
      timestamp: DateTime.parse(json['timestamp'] as String),
      operatorId: json['operatorId'] as String,
      photoPath: json['photoPath'] as String?,
      croppedPhotoPath: json['croppedPhotoPath'] as String?,
      countingRegion: json['countingRegion'] is Map<String, dynamic>
          ? CountingRegion.fromJson(
              json['countingRegion'] as Map<String, dynamic>)
          : null,
      notes: json['notes'] as String?,
      itemName: json['itemName'] as String?,
      itemAllocations: (json['itemAllocations'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(LayerItemAllocation.fromJson)
          .toList(),
      modelVersion:
          json['modelVersion'] as String? ?? 'yolo11n_carton_seg_v1_3',
      averageConfidence: (json['averageConfidence'] as num? ?? 0.0).toDouble(),
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == (json['syncStatus'] as String? ?? 'pending'),
        orElse: () => SyncStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> toJson(LayerRecord record) {
    return {
      'id': record.id,
      'truckId': record.truckId,
      'layerNumber': record.layerNumber,
      'cartonCount': record.cartonCount,
      'defectCount': record.defectCount,
      'timestamp': record.timestamp.toIso8601String(),
      'operatorId': record.operatorId,
      'photoPath': record.photoPath,
      'croppedPhotoPath': record.croppedPhotoPath,
      'countingRegion': record.countingRegion?.toJson(),
      'notes': record.notes,
      'itemName': record.itemName,
      'itemAllocations': record.itemAllocations
          .map((allocation) => allocation.toJson())
          .toList(),
      'modelVersion': record.modelVersion,
      'averageConfidence': record.averageConfidence,
      'syncStatus': record.syncStatus.name,
      'createdAt': record.createdAt.toIso8601String(),
      'updatedAt': record.updatedAt.toIso8601String(),
      'isDeleted': record.isDeleted,
    };
  }
}
