import '../../domain/entities/defect.dart';
import '../../../camera/domain/entities/detection.dart';

class DefectModel {
  static DefectRecord fromJson(Map<String, dynamic> json) {
    final bboxMap = json['boundingBox'] as Map<String, dynamic>;
    return DefectRecord(
      id: json['id'] as String,
      layerId: json['layerId'] as String,
      defectType: DefectType.values.firstWhere(
        (e) => e.name == (json['defectType'] as String),
        orElse: () => DefectType.unknown,
      ),
      boundingBox: BoundingBox(
        xMin: (bboxMap['xMin'] as num).toDouble(),
        yMin: (bboxMap['yMin'] as num).toDouble(),
        xMax: (bboxMap['xMax'] as num).toDouble(),
        yMax: (bboxMap['yMax'] as num).toDouble(),
      ),
      severity: DefectSeverity.values.firstWhere(
        (e) => e.name == (json['severity'] as String),
        orElse: () => DefectSeverity.medium,
      ),
      confidence: (json['confidence'] as num? ?? 0.0).toDouble(),
      confirmedByOperator: json['confirmedByOperator'] as bool? ?? true,
      notes: json['notes'] as String?,
      evidencePhotoPath: json['evidencePhotoPath'] as String?,
      modelVersion: json['modelVersion'] as String? ?? '1.0.0-DefectNet',
      detectedAt: DateTime.parse(json['detectedAt'] as String),
    );
  }

  static Map<String, dynamic> toJson(DefectRecord record) {
    return {
      'id': record.id,
      'layerId': record.layerId,
      'defectType': record.defectType.name,
      'boundingBox': {
        'xMin': record.boundingBox.xMin,
        'yMin': record.boundingBox.yMin,
        'xMax': record.boundingBox.xMax,
        'yMax': record.boundingBox.yMax,
      },
      'severity': record.severity.name,
      'confidence': record.confidence,
      'confirmedByOperator': record.confirmedByOperator,
      'notes': record.notes,
      'evidencePhotoPath': record.evidencePhotoPath,
      'modelVersion': record.modelVersion,
      'detectedAt': record.detectedAt.toIso8601String(),
    };
  }
}
