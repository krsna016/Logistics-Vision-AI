import 'package:flutter/foundation.dart';

/// Runtime-tunable carton-analysis settings. Values are also persisted by the
/// settings screen; the runtime copy avoids database work during every capture.
class AiCameraSettings {
  AiCameraSettings._();

  static final ValueNotifier<double> confidence = ValueNotifier<double>(0.27);
  static final ValueNotifier<int> inputSize = ValueNotifier<int>(960);
  static final ValueNotifier<double> iou = ValueNotifier<double>(0.70);
  static final ValueNotifier<int> cropQuality = ValueNotifier<int>(96);
  static final ValueNotifier<bool> detailedMasks = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> showTimings = ValueNotifier<bool>(false);

  static void apply({
    required double confidenceValue,
    required int inputSizeValue,
    required double iouValue,
    required int cropQualityValue,
    required bool detailedMasksValue,
    required bool showTimingsValue,
  }) {
    confidence.value = confidenceValue;
    inputSize.value = inputSizeValue == 640 ? 640 : 960;
    iou.value = iouValue;
    cropQuality.value = cropQualityValue;
    detailedMasks.value = detailedMasksValue;
    showTimings.value = showTimingsValue;
  }
}
