import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'dart:math' as math;

class ImagePreprocessor {
  final int targetWidth;
  final int targetHeight;

  ImagePreprocessor({this.targetWidth = 640, this.targetHeight = 640});

  /// Prepares the camera frame for ONNX Runtime.
  /// Handles Resize, Normalize, RGB Conversion, Padding, Aspect Ratio.
  Float32List process(CameraImage image) {
    final output = Float32List(3 * targetHeight * targetWidth);
    final scale =
        math.min(targetWidth / image.width, targetHeight / image.height);
    final resizedWidth = (image.width * scale).round();
    final resizedHeight = (image.height * scale).round();
    final padX = (targetWidth - resizedWidth) / 2.0;
    final padY = (targetHeight - resizedHeight) / 2.0;

    for (var y = 0; y < targetHeight; y++) {
      for (var x = 0; x < targetWidth; x++) {
        final inside = x >= padX &&
            x < padX + resizedWidth &&
            y >= padY &&
            y < padY + resizedHeight;
        final sourceX = inside
            ? (((x - padX) / scale).floor()).clamp(0, image.width - 1)
            : 0;
        final sourceY = inside
            ? (((y - padY) / scale).floor()).clamp(0, image.height - 1)
            : 0;
        final rgb = inside
            ? _readRgb(image, sourceX, sourceY)
            : const [114.0, 114.0, 114.0];
        final index = y * targetWidth + x;
        output[index] = rgb[0] / 255.0;
        output[targetWidth * targetHeight + index] = rgb[1] / 255.0;
        output[2 * targetWidth * targetHeight + index] = rgb[2] / 255.0;
      }
    }
    return output;
  }

  List<double> _readRgb(CameraImage image, int x, int y) {
    if (image.planes.length < 3) {
      final plane = image.planes.first;
      final value = plane.bytes[y * plane.bytesPerRow + x].toDouble();
      return [value, value, value];
    }

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];
    final yValue = yPlane.bytes[y * yPlane.bytesPerRow + x].toDouble();
    final uvX = x ~/ 2;
    final uvY = y ~/ 2;
    final uIndex = uvY * uPlane.bytesPerRow + uvX * uPlane.bytesPerPixel!;
    final vIndex = uvY * vPlane.bytesPerRow + uvX * vPlane.bytesPerPixel!;
    final u = uPlane.bytes[uIndex].toDouble() - 128.0;
    final v = vPlane.bytes[vIndex].toDouble() - 128.0;
    return [
      (yValue + 1.402 * v).clamp(0.0, 255.0),
      (yValue - 0.344136 * u - 0.714136 * v).clamp(0.0, 255.0),
      (yValue + 1.772 * u).clamp(0.0, 255.0),
    ];
  }
}
