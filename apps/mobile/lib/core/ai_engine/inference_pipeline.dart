import 'manager/model_manager.dart';
import 'modules/detection_validator.dart';
import 'modules/image_preprocessor.dart';
import 'modules/performance_monitor.dart';

/// Shared AI components for the still-image carton analysis workflow.
///
/// Live camera-frame inference was intentionally removed: carton analysis is
/// performed once on the operator's captured crop.
class InferencePipeline {
  final ModelManager modelManager;
  final ImagePreprocessor preprocessor;
  final DetectionValidator validator;
  final PerformanceMonitor performanceMonitor;

  InferencePipeline({
    required this.modelManager,
    required this.preprocessor,
    required this.validator,
    required this.performanceMonitor,
  });
}
