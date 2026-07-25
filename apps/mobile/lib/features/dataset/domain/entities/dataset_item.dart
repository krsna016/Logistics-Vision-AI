import 'package:flutter/foundation.dart';

@immutable
class DatasetItem {
  final String id;
  final DateTime timestamp;
  final String phoneModel;
  final String cameraResolution;
  final String orientation;
  final double brightness;
  final double exposure;
  final double sharpness;
  final String warehouseId;
  final String? truckId;
  final String? operatorId;
  final String? notes;
  final String imagePath;
  final String metadataPath;
  final String? thumbnailPath;

  const DatasetItem({
    required this.id,
    required this.timestamp,
    required this.phoneModel,
    required this.cameraResolution,
    required this.orientation,
    required this.brightness,
    required this.exposure,
    required this.sharpness,
    required this.warehouseId,
    this.truckId,
    this.operatorId,
    this.notes,
    required this.imagePath,
    required this.metadataPath,
    this.thumbnailPath,
  });

  double get qualityScore {
    // Normalize and blend exposure, brightness, and sharpness into a single rating
    final double normalizedSharp = (sharpness / 100.0).clamp(0.0, 1.0);
    final double normalizedExposure = (1.0 - ((exposure - 128.0).abs() / 128.0)).clamp(0.0, 1.0);
    return (normalizedSharp * 0.6) + (normalizedExposure * 0.4);
  }

  DatasetItem copyWith({
    String? id,
    DateTime? timestamp,
    String? phoneModel,
    String? cameraResolution,
    String? orientation,
    double? brightness,
    double? exposure,
    double? sharpness,
    String? warehouseId,
    String? truckId,
    String? operatorId,
    String? notes,
    String? imagePath,
    String? metadataPath,
    String? thumbnailPath,
  }) {
    return DatasetItem(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      phoneModel: phoneModel ?? this.phoneModel,
      cameraResolution: cameraResolution ?? this.cameraResolution,
      orientation: orientation ?? this.orientation,
      brightness: brightness ?? this.brightness,
      exposure: exposure ?? this.exposure,
      sharpness: sharpness ?? this.sharpness,
      warehouseId: warehouseId ?? this.warehouseId,
      truckId: truckId ?? this.truckId,
      operatorId: operatorId ?? this.operatorId,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      metadataPath: metadataPath ?? this.metadataPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }
}
