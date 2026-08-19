import 'package:flutter/foundation.dart';

/// Runtime-tunable carton-analysis settings. Values are also persisted by the
/// settings screen; the runtime copy avoids database work during every capture.
class AiCameraSettings {
  AiCameraSettings._();

  static const int modelInputSize = 960;

  static final ValueNotifier<double> confidence = ValueNotifier<double>(0.27);
  static final ValueNotifier<double> iou = ValueNotifier<double>(0.70);
  static final ValueNotifier<int> cropQuality = ValueNotifier<int>(98);
  static final ValueNotifier<bool> detailedMasks = ValueNotifier<bool>(true);
  static final ValueNotifier<int> processingThreads = ValueNotifier<int>(4);
  static final ValueNotifier<bool> showDatabaseIds = ValueNotifier<bool>(false);

  static void apply({
    required double confidenceValue,
    required double iouValue,
    required int cropQualityValue,
    required bool detailedMasksValue,
    required int processingThreadsValue,
    bool showDatabaseIdsValue = false,
  }) {
    confidence.value = confidenceValue.clamp(0.05, 1.0).toDouble();
    iou.value = iouValue.clamp(0.20, 0.95).toDouble();
    cropQuality.value = cropQualityValue.clamp(85, 100).toInt();
    detailedMasks.value = detailedMasksValue;
    processingThreads.value = processingThreadsValue >= 4 ? 4 : 2;
    showDatabaseIds.value = showDatabaseIdsValue;
  }
}
