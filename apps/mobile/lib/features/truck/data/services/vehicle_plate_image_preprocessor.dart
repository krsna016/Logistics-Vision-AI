import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class VehiclePlateImagePreprocessor {
  VehiclePlateImagePreprocessor._();

  static Future<String> createFocusedImage(String sourcePath) async {
    final directory = await getTemporaryDirectory();
    final outputPath =
        '${directory.path}/vehicle_plate_${DateTime.now().microsecondsSinceEpoch}.jpg';
    return Isolate.run(
        () => _createFocusedImageInIsolate(sourcePath, outputPath));
  }

  static String _createFocusedImageInIsolate(
    String sourcePath,
    String outputPath,
  ) {
    final bytes = File(sourcePath).readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw StateError('Could not decode the captured truck image.');
    }

    final oriented = img.bakeOrientation(decoded);
    final plateBox = _findYellowPlate(oriented);
    final crop = plateBox == null
        ? _centerCrop(oriented)
        : _cropWithPadding(oriented, plateBox);
    final enlarged = img.copyResize(
      crop,
      width: math.max(crop.width * 2, 640),
      interpolation: img.Interpolation.cubic,
    );

    // Use one focused, enhanced crop. Dark characters on reflective yellow
    // plates are easier for OCR after this grayscale/high-contrast pass.
    final enhanced = img.adjustColor(
      img.Image.from(enlarged),
      contrast: 1.45,
      saturation: 0,
      brightness: 1.05,
    );
    File(outputPath).writeAsBytesSync(img.encodeJpg(enhanced, quality: 95));
    return outputPath;
  }

  static img.Image _centerCrop(img.Image source) {
    final width = (source.width * 0.86).round();
    final height = (source.height * 0.38).round();
    return img.copyCrop(
      source,
      x: ((source.width - width) / 2).round(),
      y: ((source.height * 0.42) - height / 2)
          .round()
          .clamp(0, source.height - height),
      width: width,
      height: height,
    );
  }

  static img.Image _cropWithPadding(img.Image source, _Box box) {
    final paddingX = (box.width * 0.18).round();
    final paddingY = (box.height * 0.28).round();
    final left = (box.left - paddingX).clamp(0, source.width - 1);
    final top = (box.top - paddingY).clamp(0, source.height - 1);
    final right = (box.right + paddingX).clamp(left + 1, source.width);
    final bottom = (box.bottom + paddingY).clamp(top + 1, source.height);
    return img.copyCrop(
      source,
      x: left,
      y: top,
      width: right - left,
      height: bottom - top,
    );
  }

  static _Box? _findYellowPlate(img.Image source) {
    final analysisWidth = math.min(240, source.width);
    final analysis = img.copyResize(source, width: analysisWidth);
    final scale = source.width / analysis.width;
    final visited = Uint8List(analysis.width * analysis.height);
    _Box? best;
    var bestScore = 0.0;

    for (var y = 0; y < analysis.height; y++) {
      for (var x = 0; x < analysis.width; x++) {
        final index = y * analysis.width + x;
        if (visited[index] == 1 || !_isYellow(analysis.getPixel(x, y))) {
          continue;
        }
        final queue = <int>[index];
        visited[index] = 1;
        var head = 0;
        var count = 0;
        var left = x;
        var right = x;
        var top = y;
        var bottom = y;
        while (head < queue.length) {
          final current = queue[head++];
          final currentX = current % analysis.width;
          final currentY = current ~/ analysis.width;
          count++;
          left = math.min(left, currentX);
          right = math.max(right, currentX);
          top = math.min(top, currentY);
          bottom = math.max(bottom, currentY);
          for (final dy in const [-1, 0, 1]) {
            for (final dx in const [-1, 0, 1]) {
              final nextX = currentX + dx;
              final nextY = currentY + dy;
              if (nextX < 0 ||
                  nextY < 0 ||
                  nextX >= analysis.width ||
                  nextY >= analysis.height) {
                continue;
              }
              final next = nextY * analysis.width + nextX;
              if (visited[next] == 0 &&
                  _isYellow(analysis.getPixel(nextX, nextY))) {
                visited[next] = 1;
                queue.add(next);
              }
            }
          }
        }

        final boxWidth = right - left + 1;
        final boxHeight = bottom - top + 1;
        if (count < 80 || boxWidth < 18 || boxHeight < 8) continue;
        final aspect = boxWidth / boxHeight;
        if (aspect < 0.8 || aspect > 7.0) continue;
        final rectangularity = count / (boxWidth * boxHeight);
        final score =
            count * (0.5 + rectangularity) * (aspect > 1.2 ? 1.4 : 1.0);
        if (score > bestScore) {
          bestScore = score;
          best = _Box(
            (left * scale).round(),
            (top * scale).round(),
            ((right + 1) * scale).round(),
            ((bottom + 1) * scale).round(),
          );
        }
      }
    }
    return best;
  }

  static bool _isYellow(img.Pixel pixel) {
    final red = pixel.r.toInt();
    final green = pixel.g.toInt();
    final blue = pixel.b.toInt();
    return red > 110 &&
        green > 75 &&
        blue < 145 &&
        red > blue * 1.15 &&
        green > blue * 0.9;
  }
}

class _Box {
  final int left;
  final int top;
  final int right;
  final int bottom;

  const _Box(this.left, this.top, this.right, this.bottom);

  int get width => right - left;
  int get height => bottom - top;
}
