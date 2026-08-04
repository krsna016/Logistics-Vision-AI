import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as img;

import '../../../../services/network_service.dart';
import '../../domain/entities/detection.dart';
import '../../domain/entities/inference_telemetry.dart';
import '../../domain/repositories/inference_repository.dart';

/// Hosted implementation of the exact Roboflow Universe model `box-counting/4`.
class RoboflowInferenceRepository implements InferenceRepository {
  final NetworkService _network;
  int _totalDetections = 0;
  int _frames = 0;
  double _totalLatencyMs = 0;

  RoboflowInferenceRepository({NetworkService? network})
      : _network = network ?? NetworkService();

  @override
  Future<void> loadModel() async {
    // The model is hosted by Roboflow. The backend validates the configured
    // model id and keeps the Roboflow API key out of the mobile binary.
  }

  @override
  Future<List<Detection>> runInference(CameraImage image) async {
    final converted = _cameraImageToJpeg(image);
    return _infer(converted,
        imageWidth: image.width, imageHeight: image.height);
  }

  @override
  Future<List<Detection>> runGalleryInference(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    return _infer(
      bytes,
      imageWidth: decoded?.width ?? 0,
      imageHeight: decoded?.height ?? 0,
    );
  }

  Future<List<Detection>> _infer(
    List<int> bytes, {
    required int imageWidth,
    required int imageHeight,
  }) async {
    final stopwatch = Stopwatch()..start();
    final response = await _network.client.post<dynamic>(
      '/inference/box-counting',
      data: FormData.fromMap({
        'image': MultipartFile.fromBytes(bytes, filename: 'frame.jpg'),
      }),
    );
    stopwatch.stop();

    final data = response.data;
    final predictions = data is Map<String, dynamic>
        ? data['predictions']
        : data is Map
            ? data['predictions']
            : null;
    if (predictions is! List) return const [];
    final imageMetadata = data is Map ? data['image'] : null;
    final responseWidth =
        imageMetadata is Map ? _number(imageMetadata['width']) : 0;
    final responseHeight =
        imageMetadata is Map ? _number(imageMetadata['height']) : 0;

    final detections = <Detection>[];
    for (var index = 0; index < predictions.length; index++) {
      final prediction = predictions[index];
      if (prediction is! Map) continue;
      final confidence = _number(prediction['confidence']);
      final x = _number(prediction['x']);
      final y = _number(prediction['y']);
      final width = _number(prediction['width']);
      final height = _number(prediction['height']);
      // Roboflow returns pixel coordinates; the app overlay consumes 0..1.
      final widthReference = imageWidth > 0
          ? imageWidth.toDouble()
          : (responseWidth > 0 ? responseWidth : 640);
      final heightReference = imageHeight > 0
          ? imageHeight.toDouble()
          : (responseHeight > 0 ? responseHeight : 640);
      detections.add(Detection(
        id: 'roboflow-cardbox-$index',
        label: (prediction['class'] ?? 'cardboxes').toString(),
        confidence: confidence,
        boundingBox: BoundingBox(
          xMin: ((x - width / 2) / widthReference).clamp(0.0, 1.0),
          yMin: ((y - height / 2) / heightReference).clamp(0.0, 1.0),
          xMax: ((x + width / 2) / widthReference).clamp(0.0, 1.0),
          yMax: ((y + height / 2) / heightReference).clamp(0.0, 1.0),
        ),
      ));
    }
    _frames++;
    _totalDetections += detections.length;
    _totalLatencyMs += stopwatch.elapsedMicroseconds / 1000.0;
    return detections;
  }

  double _number(dynamic value) => value is num ? value.toDouble() : 0.0;

  List<int> _cameraImageToJpeg(CameraImage source) {
    final output = img.Image(width: source.width, height: source.height);
    final yPlane = source.planes.first;
    final uPlane = source.planes.length > 1 ? source.planes[1] : null;
    final vPlane = source.planes.length > 2 ? source.planes[2] : null;
    final isBgra = source.planes.length == 1;
    final pixelStride = yPlane.bytesPerPixel ?? (isBgra ? 4 : 1);

    for (var y = 0; y < source.height; y++) {
      for (var x = 0; x < source.width; x++) {
        if (isBgra) {
          final offset = y * yPlane.bytesPerRow + x * pixelStride;
          output.setPixelRgb(x, y, yPlane.bytes[offset + 2],
              yPlane.bytes[offset + 1], yPlane.bytes[offset]);
          continue;
        }
        final yValue = yPlane.bytes[y * yPlane.bytesPerRow + x].toDouble();
        final uvX = x ~/ 2;
        final uvY = y ~/ 2;
        final uIndex = uvY * (uPlane?.bytesPerRow ?? 0) +
            uvX * (uPlane?.bytesPerPixel ?? 1);
        final vIndex = uvY * (vPlane?.bytesPerRow ?? 0) +
            uvX * (vPlane?.bytesPerPixel ?? 1);
        final u =
            (uPlane == null ? 128.0 : uPlane.bytes[uIndex].toDouble()) - 128;
        final v =
            (vPlane == null ? 128.0 : vPlane.bytes[vIndex].toDouble()) - 128;
        output.setPixelRgb(
          x,
          y,
          (yValue + 1.402 * v).round().clamp(0, 255),
          (yValue - 0.344136 * u - 0.714136 * v).round().clamp(0, 255),
          (yValue + 1.772 * u).round().clamp(0, 255),
        );
      }
    }
    return img.encodeJpg(output, quality: 85);
  }

  @override
  void setDebugMode(bool enabled) {}

  @override
  InferenceTelemetry getTelemetry() {
    return InferenceTelemetry(
      fps: _frames == 0 ? 0 : 1000 / (_totalLatencyMs / _frames),
      inferenceTimeMs: _frames == 0 ? 0 : _totalLatencyMs / _frames,
      totalDetectionsCount: _totalDetections,
      droppedFramesCount: 0,
    );
  }

  @override
  Future<void> release() async {}
}
