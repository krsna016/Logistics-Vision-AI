import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../camera/domain/entities/detection.dart';
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

/// A four-corner counting area expressed as fractions of the upright original
/// image. The corners can describe a perspective view of a carton layer while
/// keeping the full photo available for audit.
@immutable
class CountingRegion {
  final CountingPoint topLeft;
  final CountingPoint topRight;
  final CountingPoint bottomRight;
  final CountingPoint bottomLeft;

  const CountingRegion({
    required this.topLeft,
    required this.topRight,
    required this.bottomRight,
    required this.bottomLeft,
  });

  /// Retains compatibility with the rectangular selection saved by earlier
  /// versions while allowing new records to store independent corners.
  factory CountingRegion.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('topLeft')) {
      return CountingRegion(
        topLeft:
            CountingPoint.fromJson(json['topLeft'] as Map<String, dynamic>),
        topRight:
            CountingPoint.fromJson(json['topRight'] as Map<String, dynamic>),
        bottomRight:
            CountingPoint.fromJson(json['bottomRight'] as Map<String, dynamic>),
        bottomLeft:
            CountingPoint.fromJson(json['bottomLeft'] as Map<String, dynamic>),
      );
    }
    final left = (json['left'] as num).toDouble();
    final top = (json['top'] as num).toDouble();
    final right = (json['right'] as num).toDouble();
    final bottom = (json['bottom'] as num).toDouble();
    return CountingRegion.rectangle(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  CountingRegion.rectangle({
    required double left,
    required double top,
    required double right,
    required double bottom,
  })  : topLeft = CountingPoint(left, top),
        topRight = CountingPoint(right, top),
        bottomRight = CountingPoint(right, bottom),
        bottomLeft = CountingPoint(left, bottom);

  Map<String, dynamic> toJson() => {
        'topLeft': topLeft.toJson(),
        'topRight': topRight.toJson(),
        'bottomRight': bottomRight.toJson(),
        'bottomLeft': bottomLeft.toJson(),
      };
}

@immutable
class CountingPoint {
  final double x;
  final double y;

  const CountingPoint(this.x, this.y);

  Map<String, double> toJson() => {'x': x, 'y': y};

  factory CountingPoint.fromJson(Map<String, dynamic> json) => CountingPoint(
        (json['x'] as num).toDouble(),
        (json['y'] as num).toDouble(),
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
  final String? croppedPhotoPath;
  final CountingRegion? countingRegion;
  final List<Detection> detections;
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
    this.croppedPhotoPath,
    this.countingRegion,
    this.detections = const [],
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

  /// Extracts just the visible operator notes, stripping out internal [SPLIT_DATA] blocks.
  String? get displayNotes {
    String baseNote = '';
    if (notes != null && notes!.isNotEmpty) {
      final splitIndex = notes!.indexOf('[SPLIT_DATA]:');
      if (splitIndex == -1) {
        baseNote = notes!;
      } else {
        baseNote = notes!.substring(0, splitIndex).trim();
        if (baseNote.endsWith('|')) {
          baseNote = baseNote.substring(0, baseNote.length - 1).trim();
        }
      }
    }
    
    if (splitData != null) {
      final splitWarning = '-- This layer contains two merged images (Split Mode) --';
      return baseNote.isEmpty ? splitWarning : '$baseNote\n\n$splitWarning';
    }
    return baseNote.isEmpty ? null : baseNote;
  }

  /// Parses the internal [SPLIT_DATA] JSON block if this layer was captured in Split Mode.
  Map<String, dynamic>? get splitData {
    if (notes == null || !notes!.contains('[SPLIT_DATA]:')) return null;
    try {
      final jsonStr = notes!.substring(notes!.indexOf('[SPLIT_DATA]:') + '[SPLIT_DATA]:'.length);
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  LayerRecord copyWith({
    String? id,
    String? truckId,
    int? layerNumber,
    int? cartonCount,
    int? defectCount,
    DateTime? timestamp,
    String? operatorId,
    String? photoPath,
    String? croppedPhotoPath,
    CountingRegion? countingRegion,
    List<Detection>? detections,
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
      croppedPhotoPath: croppedPhotoPath ?? this.croppedPhotoPath,
      countingRegion: countingRegion ?? this.countingRegion,
      detections: detections ?? this.detections,
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
