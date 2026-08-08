import 'dart:ui' show Size;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

Future<List<CameraDescription>> _cachedCameras = availableCameras();

Future<List<CameraDescription>> cachedCameraDescriptions() => _cachedCameras;

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
