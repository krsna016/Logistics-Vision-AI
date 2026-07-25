import 'package:flutter/foundation.dart';
import '../../../camera/domain/entities/detection.dart';

enum DefectType {
  torn,
  crushed,
  wet,
  open,
  missingLabel,
  damagedLabel,
  broken,
  deformed,
  unknown;

  String get displayName {
    switch (this) {
      case DefectType.torn:
        return 'Torn Carton';
      case DefectType.crushed:
        return 'Crushed Carton';
      case DefectType.wet:
        return 'Wet Carton';
      case DefectType.open:
        return 'Open Flaps';
      case DefectType.missingLabel:
        return 'Missing Shipping Label';
      case DefectType.damagedLabel:
        return 'Damaged Shipping Label';
      case DefectType.broken:
        return 'Broken Packing';
      case DefectType.deformed:
        return 'Deformed Box';
      case DefectType.unknown:
        return 'Unknown Defect';
    }
  }
}

enum DefectSeverity {
  critical,
  high,
  medium,
  low,
  informational;

  String get displayName => name.toUpperCase();
}

@immutable
class DefectRecord {
  final String id;
  final String layerId;
  final DefectType defectType;
  final BoundingBox boundingBox;
  final DefectSeverity severity;
  final double confidence;
  final bool confirmedByOperator;
  final String? notes;
  final String? evidencePhotoPath;
  final String modelVersion;
  final DateTime detectedAt;

  const DefectRecord({
    required this.id,
    required this.layerId,
    required this.defectType,
    required this.boundingBox,
    required this.severity,
    required this.confidence,
    this.confirmedByOperator = true,
    this.notes,
    this.evidencePhotoPath,
    required this.modelVersion,
    required this.detectedAt,
  });

  DefectRecord copyWith({
    String? id,
    String? layerId,
    DefectType? defectType,
    BoundingBox? boundingBox,
    DefectSeverity? severity,
    double? confidence,
    bool? confirmedByOperator,
    String? notes,
    String? evidencePhotoPath,
    String? modelVersion,
    DateTime? detectedAt,
  }) {
    return DefectRecord(
      id: id ?? this.id,
      layerId: layerId ?? this.layerId,
      defectType: defectType ?? this.defectType,
      boundingBox: boundingBox ?? this.boundingBox,
      severity: severity ?? this.severity,
      confidence: confidence ?? this.confidence,
      confirmedByOperator: confirmedByOperator ?? this.confirmedByOperator,
      notes: notes ?? this.notes,
      evidencePhotoPath: evidencePhotoPath ?? this.evidencePhotoPath,
      modelVersion: modelVersion ?? this.modelVersion,
      detectedAt: detectedAt ?? this.detectedAt,
    );
  }
}
