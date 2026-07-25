import 'package:camera/camera.dart';
import '../entities/detection.dart';
import '../entities/inference_telemetry.dart';

abstract class InferenceRepository {
  /// Check model availability, verify integrity, and load weights into memory.
  Future<void> loadModel();

  /// Execute pre-processing, model inference, and post-processing on a camera image.
  Future<List<Detection>> runInference(CameraImage image);

  /// Toggle debug visualizations and stats overlays.
  void setDebugMode(bool enabled);

  /// Get current performance metrics and latencies.
  InferenceTelemetry getTelemetry();

  /// Dispose loaded assets and release hardware accelerators.
  Future<void> release();
}
