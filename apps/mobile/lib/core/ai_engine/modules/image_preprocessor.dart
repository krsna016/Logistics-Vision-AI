import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

class ImagePreprocessor {
  final int targetWidth;
  final int targetHeight;

  ImagePreprocessor({this.targetWidth = 640, this.targetHeight = 640});

  /// Copies the ephemeral camera planes and performs the expensive YUV-to-RGB
  /// conversion away from Flutter's UI isolate. This is the main protection
  /// against preview jank while the model is running.
  Future<Float32List> processAsync(CameraImage image) {
    final snapshot = _CameraImageSnapshot(
      width: image.width,
      height: image.height,
      planes: image.planes
          .map(
            (plane) => _CameraPlaneSnapshot(
              bytes: Uint8List.fromList(plane.bytes),
              bytesPerRow: plane.bytesPerRow,
              bytesPerPixel: plane.bytesPerPixel,
            ),
          )
          .toList(growable: false),
    );
    final targetWidth = this.targetWidth;
    final targetHeight = this.targetHeight;
    return Isolate.run(
      () => _processSnapshot(snapshot, targetWidth, targetHeight),
    );
  }

  /// Decodes, orients and letterboxes a captured photo off the UI isolate.
  Future<PreparedImage> processImageFileAsync(String path) {
    final targetWidth = this.targetWidth;
    final targetHeight = this.targetHeight;
    return Isolate.run(() {
      final bytes = File(path).readAsBytesSync();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw const FormatException('Unsupported captured image format');
      }
      final oriented = img.bakeOrientation(decoded);
      final processor = ImagePreprocessor(
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );
      return PreparedImage(
        tensor: processor.processRgbImage(oriented),
        width: oriented.width,
        height: oriented.height,
      );
    });
  }

  /// Prepares the camera frame for ONNX Runtime.
  /// Handles Resize, Normalize, RGB Conversion, Padding, Aspect Ratio.
  Float32List process(CameraImage image) {
    final output = Float32List(3 * targetHeight * targetWidth);
    final scale =
        math.min(targetWidth / image.width, targetHeight / image.height);
    final resizedWidth = (image.width * scale).round();
    final resizedHeight = (image.height * scale).round();
    final padX = (targetWidth - resizedWidth) ~/ 2;
    final padY = (targetHeight - resizedHeight) ~/ 2;
    final endX = padX + resizedWidth;
    final endY = padY + resizedHeight;
    final planeSize = targetWidth * targetHeight;
    final yPlane = image.planes.isNotEmpty ? image.planes[0] : null;
    final uPlane = image.planes.length >= 3 ? image.planes[1] : null;
    final vPlane = image.planes.length >= 3 ? image.planes[2] : null;

    for (var y = 0; y < targetHeight; y++) {
      for (var x = 0; x < targetWidth; x++) {
        final inside = x >= padX && x < endX && y >= padY && y < endY;
        var red = 114.0;
        var green = 114.0;
        var blue = 114.0;
        if (inside && yPlane != null) {
          final sourceX =
              (((x - padX) / scale).floor()).clamp(0, image.width - 1);
          final sourceY =
              (((y - padY) / scale).floor()).clamp(0, image.height - 1);
          final yValue =
              yPlane.bytes[sourceY * yPlane.bytesPerRow + sourceX].toDouble();
          if (uPlane != null && vPlane != null) {
            final uvX = sourceX ~/ 2;
            final uvY = sourceY ~/ 2;
            final uIndex =
                uvY * uPlane.bytesPerRow + uvX * uPlane.bytesPerPixel!;
            final vIndex =
                uvY * vPlane.bytesPerRow + uvX * vPlane.bytesPerPixel!;
            final u = uPlane.bytes[uIndex].toDouble() - 128.0;
            final v = vPlane.bytes[vIndex].toDouble() - 128.0;
            red = (yValue + 1.402 * v).clamp(0.0, 255.0);
            green = (yValue - 0.344136 * u - 0.714136 * v).clamp(0.0, 255.0);
            blue = (yValue + 1.772 * u).clamp(0.0, 255.0);
          } else {
            red = green = blue = yValue;
          }
        }
        final index = y * targetWidth + x;
        output[index] = red / 255.0;
        output[planeSize + index] = green / 255.0;
        output[2 * planeSize + index] = blue / 255.0;
      }
    }
    return output;
  }

  static Float32List _processSnapshot(
    _CameraImageSnapshot image,
    int targetWidth,
    int targetHeight,
  ) {
    final output = Float32List(3 * targetHeight * targetWidth);
    final scale =
        math.min(targetWidth / image.width, targetHeight / image.height);
    final resizedWidth = (image.width * scale).round();
    final resizedHeight = (image.height * scale).round();
    final padX = (targetWidth - resizedWidth) ~/ 2;
    final padY = (targetHeight - resizedHeight) ~/ 2;
    final endX = padX + resizedWidth;
    final endY = padY + resizedHeight;
    final planeSize = targetWidth * targetHeight;
    final yPlane = image.planes.isNotEmpty ? image.planes[0] : null;
    final uPlane = image.planes.length >= 3 ? image.planes[1] : null;
    final vPlane = image.planes.length >= 3 ? image.planes[2] : null;

    for (var y = 0; y < targetHeight; y++) {
      for (var x = 0; x < targetWidth; x++) {
        final inside = x >= padX && x < endX && y >= padY && y < endY;
        var red = 114.0;
        var green = 114.0;
        var blue = 114.0;
        if (inside && yPlane != null) {
          final sourceX =
              (((x - padX) / scale).floor()).clamp(0, image.width - 1);
          final sourceY =
              (((y - padY) / scale).floor()).clamp(0, image.height - 1);
          final yValue =
              yPlane.bytes[sourceY * yPlane.bytesPerRow + sourceX].toDouble();
          if (uPlane != null && vPlane != null) {
            final uvX = sourceX ~/ 2;
            final uvY = sourceY ~/ 2;
            final uIndex =
                uvY * uPlane.bytesPerRow + uvX * (uPlane.bytesPerPixel ?? 1);
            final vIndex =
                uvY * vPlane.bytesPerRow + uvX * (vPlane.bytesPerPixel ?? 1);
            final u = uPlane.bytes[uIndex].toDouble() - 128.0;
            final v = vPlane.bytes[vIndex].toDouble() - 128.0;
            red = (yValue + 1.402 * v).clamp(0.0, 255.0);
            green = (yValue - 0.344136 * u - 0.714136 * v).clamp(0.0, 255.0);
            blue = (yValue + 1.772 * u).clamp(0.0, 255.0);
          } else {
            red = green = blue = yValue;
          }
        }
        final index = y * targetWidth + x;
        output[index] = red / 255.0;
        output[planeSize + index] = green / 255.0;
        output[2 * planeSize + index] = blue / 255.0;
      }
    }
    return output;
  }

  /// Prepares a decoded gallery image using the same letterbox and RGB
  /// normalization as the live camera pipeline.
  Float32List processRgbImage(
    img.Image image, {
    double brightness = 1.0,
    double contrast = 1.0,
  }) {
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
        final pixel = inside ? image.getPixel(sourceX, sourceY) : null;
        double adjust(num value) =>
            (((value.toDouble() * brightness) - 128.0) * contrast + 128.0)
                .clamp(0.0, 255.0);
        final red = pixel == null ? 114.0 : adjust(pixel.r);
        final green = pixel == null ? 114.0 : adjust(pixel.g);
        final blue = pixel == null ? 114.0 : adjust(pixel.b);
        final index = y * targetWidth + x;
        output[index] = red / 255.0;
        output[targetWidth * targetHeight + index] = green / 255.0;
        output[2 * targetWidth * targetHeight + index] = blue / 255.0;
      }
    }
    return output;
  }
}

class PreparedImage {
  final Float32List tensor;
  final int width;
  final int height;

  const PreparedImage({
    required this.tensor,
    required this.width,
    required this.height,
  });
}

class _CameraImageSnapshot {
  final int width;
  final int height;
  final List<_CameraPlaneSnapshot> planes;

  const _CameraImageSnapshot({
    required this.width,
    required this.height,
    required this.planes,
  });
}

class _CameraPlaneSnapshot {
  final Uint8List bytes;
  final int bytesPerRow;
  final int? bytesPerPixel;

  const _CameraPlaneSnapshot({
    required this.bytes,
    required this.bytesPerRow,
    required this.bytesPerPixel,
  });
}
