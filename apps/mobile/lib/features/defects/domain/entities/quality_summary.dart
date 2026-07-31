import 'package:flutter/foundation.dart';
import 'defect.dart';

@immutable
class QualitySummary {
  final int totalCartons;
  final int defectiveCartons;
  final List<DefectRecord> defects;
  final String? modelVersion;

  const QualitySummary({
    required this.totalCartons,
    required this.defectiveCartons,
    required this.defects,
    this.modelVersion = '1.0.0-DefectNet',
  });

  double get defectPercentage {
    if (totalCartons == 0) return 0.0;
    return (defectiveCartons / totalCartons) * 100.0;
  }

  /// Calculates an overall layer quality score between 0.0 (Worst) and 100.0 (Perfect)
  double get qualityScore {
    if (totalCartons == 0) return 100.0;

    // Severity penalty factors
    double penalty = 0.0;
    for (final defect in defects) {
      if (!defect.confirmedByOperator) continue;
      switch (defect.severity) {
        case DefectSeverity.critical:
          penalty += 35.0; // Heavy penalty
          break;
        case DefectSeverity.high:
          penalty += 20.0;
          break;
        case DefectSeverity.medium:
          penalty += 10.0;
          break;
        case DefectSeverity.low:
          penalty += 4.0;
          break;
        case DefectSeverity.informational:
          penalty += 1.0;
          break;
      }
    }

    return (100.0 - penalty).clamp(0.0, 100.0);
  }

  bool get hasCriticalIssues {
    return defects.any(
        (d) => d.confirmedByOperator && d.severity == DefectSeverity.critical);
  }
}
