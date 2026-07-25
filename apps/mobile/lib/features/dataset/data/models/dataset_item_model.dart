import '../../domain/entities/dataset_item.dart';

class DatasetItemModel {
  static DatasetItem fromJson(Map<String, dynamic> json) {
    return DatasetItem(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      phoneModel: json['phoneModel'] as String,
      cameraResolution: json['cameraResolution'] as String,
      orientation: json['orientation'] as String,
      brightness: (json['brightness'] as num).toDouble(),
      exposure: (json['exposure'] as num).toDouble(),
      sharpness: (json['sharpness'] as num).toDouble(),
      warehouseId: json['warehouseId'] as String,
      truckId: json['truckId'] as String?,
      operatorId: json['operatorId'] as String?,
      notes: json['notes'] as String?,
      imagePath: json['imagePath'] as String,
      metadataPath: json['metadataPath'] as String,
      thumbnailPath: json['thumbnailPath'] as String?,
    );
  }

  static Map<String, dynamic> toJson(DatasetItem item) {
    return {
      'id': item.id,
      'timestamp': item.timestamp.toIso8601String(),
      'phoneModel': item.phoneModel,
      'cameraResolution': item.cameraResolution,
      'orientation': item.orientation,
      'brightness': item.brightness,
      'exposure': item.exposure,
      'sharpness': item.sharpness,
      'warehouseId': item.warehouseId,
      'truckId': item.truckId,
      'operatorId': item.operatorId,
      'notes': item.notes,
      'imagePath': item.imagePath,
      'metadataPath': item.metadataPath,
      'thumbnailPath': item.thumbnailPath,
    };
  }
}
