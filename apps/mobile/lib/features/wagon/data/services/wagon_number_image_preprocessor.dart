import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class WagonNumberImagePreprocessor {
  WagonNumberImagePreprocessor._();

  static Future<List<String>> createVariants(String sourcePath) async {
    final directory = await getTemporaryDirectory();
    final outputPath =
        '${directory.path}/wagon_number_${DateTime.now().microsecondsSinceEpoch}.jpg';
    return Isolate.run(() => _createVariant(sourcePath, outputPath));
  }

  static List<String> _createVariant(String sourcePath, String outputPath) {
    final bytes = File(sourcePath).readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return [sourcePath];

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
    File(outputPath).writeAsBytesSync(img.encodeJpg(enlarged, quality: 94));
    return [outputPath, sourcePath];
  }
}
