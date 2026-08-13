import 'package:camera/camera.dart';
import 'dart:typed_data';
import '../entities/detection.dart';
import '../entities/inference_telemetry.dart';

abstract class InferenceRepository {
  /// Check model availability, verify integrity, and load weights into memory.
  Future<void> loadModel();

  /// Execute pre-processing, model inference, and post-processing on a camera image.
  Future<List<Detection>> runInference(CameraImage image);

  /// Run the same model once against a still image selected from the gallery.
  Future<List<Detection>> runGalleryInference(String imagePath);

  /// Run inference directly from an encoded still image already in memory.
  Future<List<Detection>> runGalleryInferenceBytes(Uint8List imageBytes);

  /// Toggle debug visualizations and stats overlays.
  void setDebugMode(bool enabled);

  /// Get current performance metrics and latencies.
  InferenceTelemetry getTelemetry();

  /// Dispose loaded assets and release hardware accelerators.
  Future<void> release();
}
