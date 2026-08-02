import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class WagonNumberImagePreprocessor {
  WagonNumberImagePreprocessor._();

  static Future<String> createFocusedImage(String sourcePath) async {
    final directory = await getTemporaryDirectory();
    final outputPath =
        '${directory.path}/wagon_number_${DateTime.now().microsecondsSinceEpoch}.jpg';
    return Isolate.run(() => _createFocusedImage(sourcePath, outputPath));
  }

  static String _createFocusedImage(String sourcePath, String outputPath) {
    final bytes = File(sourcePath).readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw StateError('Could not decode the captured wagon image.');
    }

    final oriented = img.bakeOrientation(decoded);
    final cropWidth = (oriented.width * 0.84).round();
    final cropHeight = (oriented.height * 0.62).round();
    final cropTop = ((oriented.height * 0.38) - cropHeight / 2)
        .round()
        .clamp(0, oriented.height - cropHeight);
    final crop = img.copyCrop(
      oriented,
      x: ((oriented.width - cropWidth) / 2).round(),
      y: cropTop,
      width: cropWidth,
      height: cropHeight,
    );
    final enlarged = img.copyResize(
      crop,
      width: math.max(crop.width * 2, 900),
      interpolation: img.Interpolation.cubic,
    );

    // Wagon identifiers are white paint on blue, often faded or dirty. Use
    // one enlarged, high-contrast crop for the single OCR pass.
    final enhanced = img.adjustColor(
      img.Image.from(enlarged),
      contrast: 1.5,
      saturation: 0,
      brightness: 1.08,
    );
    File(outputPath).writeAsBytesSync(img.encodeJpg(enhanced, quality: 94));
    return outputPath;
  }
}
