import 'package:flutter/foundation.dart';
import '../../../truck/domain/entities/truck.dart';

@immutable
class LayerRecord {
  final String id;
  final String truckId;
  final int layerNumber;
  final int cartonCount;
  final DateTime timestamp;
  final String operatorId;
  final String? photoPath;
  final String? notes;
  final String modelVersion;
  final double averageConfidence;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const LayerRecord({
    required this.id,
    required this.truckId,
    required this.layerNumber,
    required this.cartonCount,
    required this.timestamp,
    required this.operatorId,
    this.photoPath,
    this.notes,
    required this.modelVersion,
    required this.averageConfidence,
    this.syncStatus = SyncStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  LayerRecord copyWith({
    String? id,
    String? truckId,
    int? layerNumber,
    int? cartonCount,
    DateTime? timestamp,
    String? operatorId,
    String? photoPath,
    String? notes,
    String? modelVersion,
    double? averageConfidence,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return LayerRecord(
      id: id ?? this.id,
      truckId: truckId ?? this.truckId,
      layerNumber: layerNumber ?? this.layerNumber,
      cartonCount: cartonCount ?? this.cartonCount,
      timestamp: timestamp ?? this.timestamp,
      operatorId: operatorId ?? this.operatorId,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      modelVersion: modelVersion ?? this.modelVersion,
      averageConfidence: averageConfidence ?? this.averageConfidence,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
