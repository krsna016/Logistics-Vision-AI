import '../../domain/entities/layer.dart';
import '../../../camera/domain/entities/detection.dart';

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
      detections: (json['detections'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(detectionFromJson)
          .toList(growable: false),
      notes: json['notes'] as String?,
      itemName: json['itemName'] as String?,
      itemAllocations: (json['itemAllocations'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(LayerItemAllocation.fromJson)
          .toList(),
      modelVersion:
          json['modelVersion'] as String? ?? 'yolo11n_carton_seg_v1_3',
      averageConfidence: (json['averageConfidence'] as num? ?? 0.0).toDouble(),
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
      'detections': record.detections.map(detectionToJson).toList(),
      'notes': record.notes,
      'itemName': record.itemName,
      'itemAllocations': record.itemAllocations
          .map((allocation) => allocation.toJson())
          .toList(),
      'modelVersion': record.modelVersion,
      'averageConfidence': record.averageConfidence,
      'createdAt': record.createdAt.toIso8601String(),
      'updatedAt': record.updatedAt.toIso8601String(),
      'isDeleted': record.isDeleted,
    };
  }

  static Detection detectionFromJson(Map<String, dynamic> json) {
    final box = json['boundingBox'] as Map<String, dynamic>? ?? const {};
    return Detection(
      id: json['id'] as String? ?? '',
      boundingBox: BoundingBox(
        xMin: (box['xMin'] as num? ?? 0).toDouble(),
        yMin: (box['yMin'] as num? ?? 0).toDouble(),
        xMax: (box['xMax'] as num? ?? 0).toDouble(),
        yMax: (box['yMax'] as num? ?? 0).toDouble(),
      ),
      label: json['label'] as String? ?? 'carton',
      confidence: (json['confidence'] as num? ?? 0).toDouble(),
      trackingId: json['trackingId'] as String?,
      polygon: (json['polygon'] as List<dynamic>? ?? const [])
          .whereType<List<dynamic>>()
          .map((point) => point
              .whereType<num>()
              .map((coordinate) => coordinate.toDouble())
              .toList(growable: false))
          .where((point) => point.length >= 2)
          .toList(growable: false),
      metadata: Map<String, dynamic>.from(
        json['metadata'] as Map? ?? const <String, dynamic>{},
      ),
    );
  }

  static Map<String, dynamic> detectionToJson(Detection detection) => {
        'id': detection.id,
        'boundingBox': {
          'xMin': detection.boundingBox.xMin,
          'yMin': detection.boundingBox.yMin,
          'xMax': detection.boundingBox.xMax,
          'yMax': detection.boundingBox.yMax,
        },
        'label': detection.label,
        'confidence': detection.confidence,
        'trackingId': detection.trackingId,
        'polygon': detection.polygon,
        'metadata': detection.metadata,
      };
}
