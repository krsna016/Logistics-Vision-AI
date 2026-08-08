import 'dart:ui' show Size;
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

Future<List<CameraDescription>> _cachedCameras = availableCameras();

Future<List<CameraDescription>> cachedCameraDescriptions() => _cachedCameras;

bool cameraFrameHasSufficientQuality(
  CameraImage image,
  int sensorOrientation, {
  required double roiWidthFraction,
  required double roiHeightFraction,
}) {
  if (image.planes.length != 1 || image.planes.first.bytes.isEmpty) return true;
  final rotateDisplayAxes = sensorOrientation == 90 || sensorOrientation == 270;
  final widthFraction =
      rotateDisplayAxes ? roiHeightFraction : roiWidthFraction;
  final heightFraction =
      rotateDisplayAxes ? roiWidthFraction : roiHeightFraction;
  return lumaPlaneHasSufficientQuality(
    image.planes.first.bytes,
    width: image.width,
    height: image.height,
    bytesPerRow: image.planes.first.bytesPerRow,
    roiWidthFraction: widthFraction,
    roiHeightFraction: heightFraction,
  );
}

bool lumaPlaneHasSufficientQuality(
  Uint8List bytes, {
  required int width,
  required int height,
  required int bytesPerRow,
  required double roiWidthFraction,
  required double roiHeightFraction,
}) {
  if (width <= 0 || height <= 0 || bytesPerRow < width) return false;
  final cropWidth = (width * roiWidthFraction).round().clamp(2, width);
  final cropHeight = (height * roiHeightFraction).round().clamp(2, height);
  final left = (width - cropWidth) ~/ 2;
  final top = (height - cropHeight) ~/ 2;
  final stepX = math.max(2, cropWidth ~/ 32);
  final stepY = math.max(2, cropHeight ~/ 24);
  var count = 0;
  var sum = 0;
  var minimum = 255;
  var maximum = 0;
  var edgeSum = 0;
  var edgeCount = 0;

  for (var y = top; y < top + cropHeight; y += stepY) {
    final row = y * bytesPerRow;
    var previous = -1;
    for (var x = left; x < left + cropWidth; x += stepX) {
      final index = row + x;
      if (index >= bytes.length) return true;
      final value = bytes[index];
      sum += value;
      minimum = math.min(minimum, value);
      maximum = math.max(maximum, value);
      count++;
      if (previous >= 0) {
        edgeSum += (value - previous).abs();
        edgeCount++;
      }
      previous = value;
    }
  }

  if (count == 0 || edgeCount == 0) return false;
  final mean = sum / count;
  final averageEdge = edgeSum / edgeCount;
  return mean >= 28 &&
      mean <= 235 &&
      maximum - minimum >= 24 &&
      averageEdge >= 2.5;
}

InputImage? inputImageFromCameraFrame(
  CameraImage image,
  int sensorOrientation, {
  double roiWidthFraction = 1,
  double roiHeightFraction = 1,
}) {
  final isNv21 = defaultTargetPlatform == TargetPlatform.android &&
      image.planes.length == 1;
  final nv21Crop = isNv21
      ? _centerCropNv21(
          image.planes.first.bytes,
          width: image.width,
          height: image.height,
          bytesPerRow: image.planes.first.bytesPerRow,
          sensorOrientation: sensorOrientation,
          roiWidthFraction: roiWidthFraction,
          roiHeightFraction: roiHeightFraction,
        )
      : null;
  final bytes = nv21Crop?.bytes ??
      (image.planes.length == 1
          ? image.planes.first.bytes
          : Uint8List.fromList(
              image.planes.expand((plane) => plane.bytes).toList(),
            ));
  final metadataWidth = nv21Crop?.width ?? image.width;
  final metadataHeight = nv21Crop?.height ?? image.height;
  final rotation = switch (sensorOrientation) {
    90 => InputImageRotation.rotation90deg,
    180 => InputImageRotation.rotation180deg,
    270 => InputImageRotation.rotation270deg,
    _ => InputImageRotation.rotation0deg,
  };
  final format = defaultTargetPlatform == TargetPlatform.iOS
      ? InputImageFormat.bgra8888
      : InputImageFormat.nv21;

  return InputImage.fromBytes(
    bytes: bytes,
    metadata: InputImageMetadata(
      size: Size(metadataWidth.toDouble(), metadataHeight.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: nv21Crop?.bytesPerRow ?? image.planes.first.bytesPerRow,
    ),
  );
}

_Nv21Crop _centerCropNv21(
  Uint8List source, {
  required int width,
  required int height,
  required int bytesPerRow,
  required int sensorOrientation,
  required double roiWidthFraction,
  required double roiHeightFraction,
}) {
  if (roiWidthFraction >= 0.99 && roiHeightFraction >= 0.99) {
    return _Nv21Crop(source, width, height, bytesPerRow);
  }

  final rotateDisplayAxes = sensorOrientation == 90 || sensorOrientation == 270;
  var cropWidth =
      (width * (rotateDisplayAxes ? roiHeightFraction : roiWidthFraction))
          .round()
          .clamp(2, width);
  var cropHeight =
      (height * (rotateDisplayAxes ? roiWidthFraction : roiHeightFraction))
          .round()
          .clamp(2, height);
  cropWidth -= cropWidth.isOdd ? 1 : 0;
  cropHeight -= cropHeight.isOdd ? 1 : 0;
  final left = ((width - cropWidth) ~/ 2) & ~1;
  final top = ((height - cropHeight) ~/ 2) & ~1;
  final yPlaneSize = bytesPerRow * height;
  final outputSize = cropWidth * cropHeight * 3 ~/ 2;
  if (source.length < yPlaneSize + width * height ~/ 2 || outputSize <= 0) {
    return _Nv21Crop(source, width, height, bytesPerRow);
  }

  final output = Uint8List(outputSize);
  var outputOffset = 0;
  for (var row = 0; row < cropHeight; row++) {
    final sourceOffset = (top + row) * bytesPerRow + left;
    output.setRange(
      outputOffset,
      outputOffset + cropWidth,
      source,
      sourceOffset,
    );
    outputOffset += cropWidth;
  }
  final uvStart = yPlaneSize;
  for (var row = 0; row < cropHeight ~/ 2; row++) {
    final sourceOffset = uvStart + ((top ~/ 2) + row) * bytesPerRow + left;
    output.setRange(
      outputOffset,
      outputOffset + cropWidth,
      source,
      sourceOffset,
    );
    outputOffset += cropWidth;
  }
  return _Nv21Crop(output, cropWidth, cropHeight, cropWidth);
}

class _Nv21Crop {
  final Uint8List bytes;
  final int width;
  final int height;
  final int bytesPerRow;

  const _Nv21Crop(this.bytes, this.width, this.height, this.bytesPerRow);
}
