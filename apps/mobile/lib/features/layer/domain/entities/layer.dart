import 'package:flutter/foundation.dart';
import '../../../truck/domain/entities/truck.dart';

@immutable
class LayerItemAllocation {
  final String itemName;
  final int quantity;

  const LayerItemAllocation({required this.itemName, required this.quantity});

  Map<String, dynamic> toJson() => {
        'itemName': itemName,
        'quantity': quantity,
      };

  factory LayerItemAllocation.fromJson(Map<String, dynamic> json) =>
      LayerItemAllocation(
        itemName: (json['itemName'] as String? ?? '').trim(),
        quantity: (json['quantity'] as num? ?? 0).toInt(),
      );
}

@immutable
class LayerRecord {
  final String id;
  final String truckId;
  final int layerNumber;
  final int cartonCount;

  /// Number of defective cartons, included in [cartonCount].
  final int defectCount;
  final DateTime timestamp;
  final String operatorId;
  final String? photoPath;
  final String? notes;
  final String? itemName;
  final List<LayerItemAllocation> itemAllocations;
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
    this.defectCount = 0,
    required this.timestamp,
    required this.operatorId,
    this.photoPath,
    this.notes,
    this.itemName,
    this.itemAllocations = const [],
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
    int? defectCount,
    DateTime? timestamp,
    String? operatorId,
    String? photoPath,
    String? notes,
    String? itemName,
    List<LayerItemAllocation>? itemAllocations,
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
      defectCount: defectCount ?? this.defectCount,
      timestamp: timestamp ?? this.timestamp,
      operatorId: operatorId ?? this.operatorId,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      itemName: itemName ?? this.itemName,
      itemAllocations: itemAllocations ?? this.itemAllocations,
      modelVersion: modelVersion ?? this.modelVersion,
      averageConfidence: averageConfidence ?? this.averageConfidence,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
