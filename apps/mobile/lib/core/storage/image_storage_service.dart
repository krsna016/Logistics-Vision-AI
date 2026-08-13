import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../features/layer/domain/entities/layer.dart';

class ImageStorageService {
  Future<String> get _storagePath async {
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, 'smartload_images');
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  Future<String> saveImage(File imageFile, String prefix) async {
    final basePath = await _storagePath;
    final safePrefix = prefix.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final fileName =
        '${safePrefix.isEmpty ? 'image' : safePrefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final destination = p.join(basePath, fileName);

    await imageFile.copy(destination);
    // Returning relative path could be better, but absolute is fine for now as it's within AppDocs
    return destination;
  }

  Future<String> saveImageBytes(Uint8List bytes, String prefix) async {
    final basePath = await _storagePath;
    final safePrefix = prefix.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final fileName =
        '${safePrefix.isEmpty ? 'image' : safePrefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final destination = p.join(basePath, fileName);
    await File(destination).writeAsBytes(bytes, flush: true);
    return destination;
  }

  Future<Uint8List> createCountingCropBytes(
    String sourcePath,
    CountingRegion region,
  ) async {
    return Isolate.run(() => _createNormalizedCropBytes(
          sourcePath,
          region.toJson(),
        ));
  }

  /// Produces an upright, perspective-corrected crop for inference while
  /// preserving the full source image as the audit artifact.
  Future<String> createCountingCrop(
    String sourcePath,
    CountingRegion region, {
    required String prefix,
  }) async {
    final basePath = await _storagePath;
    final safePrefix = prefix.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    final destination = p.join(
      basePath,
      '${safePrefix.isEmpty ? 'count_crop' : safePrefix}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await Isolate.run(() => _writeNormalizedCrop(
          sourcePath,
          destination,
          region.toJson(),
        ));
    return destination;
  }

  Future<File?> getImage(String path) async {
    final file = await _storedFile(path);
    if (file == null) return null;
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  Future<void> deleteImage(String path) async {
    final file = await _storedFile(path);
    if (file == null) return;
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File?> _storedFile(String path) async {
    final root = p.normalize(await _storagePath);
    final candidate = p.normalize(path);
    final isInsideStorage =
        candidate == root || candidate.startsWith('$root${p.separator}');
    if (!isInsideStorage) return null;
    return File(candidate);
  }
}

void _writeNormalizedCrop(
  String sourcePath,
  String destinationPath,
  Map<String, dynamic> normalized,
) {
  File(destinationPath).writeAsBytesSync(
    _createNormalizedCropBytes(sourcePath, normalized),
  );
}

Uint8List _createNormalizedCropBytes(
  String sourcePath,
  Map<String, dynamic> normalized,
) {
  final decoded = img.decodeImage(File(sourcePath).readAsBytesSync());
  if (decoded == null) {
    throw const FormatException('Unsupported captured image');
  }
  final source = img.bakeOrientation(decoded);
  final points = _normalizedPoints(normalized, source.width, source.height);
  final topWidth = _distance(points[1], points[0]);
  final bottomWidth = _distance(points[2], points[3]);
  final leftHeight = _distance(points[3], points[0]);
  final rightHeight = _distance(points[2], points[1]);
  var outputWidth =
      math.max(topWidth, bottomWidth).round().clamp(1, 1920).toInt();
  var outputHeight =
      math.max(leftHeight, rightHeight).round().clamp(1, 1920).toInt();
  const maxPixels = 2500000;
  if (outputWidth * outputHeight > maxPixels) {
    final scale = math.sqrt(maxPixels / (outputWidth * outputHeight));
    outputWidth = (outputWidth * scale).round();
    outputHeight = (outputHeight * scale).round();
  }
  final homography = _destinationToSourceHomography(points);
  final cropped = img.Image(width: outputWidth, height: outputHeight);
  for (var y = 0; y < outputHeight; y++) {
    final v = outputHeight == 1 ? 0.0 : y / (outputHeight - 1);
    for (var x = 0; x < outputWidth; x++) {
      final u = outputWidth == 1 ? 0.0 : x / (outputWidth - 1);
      final divisor = homography[6] * u + homography[7] * v + 1;
      final sourceX =
          (homography[0] * u + homography[1] * v + homography[2]) / divisor;
      final sourceY =
          (homography[3] * u + homography[4] * v + homography[5]) / divisor;
      final sampleX = sourceX.round().clamp(0, source.width - 1).toInt();
      final sampleY = sourceY.round().clamp(0, source.height - 1).toInt();
      cropped.setPixel(x, y, source.getPixel(sampleX, sampleY));
    }
  }
  return Uint8List.fromList(img.encodeJpg(cropped, quality: 96));
}

double _distance(math.Point<double> a, math.Point<double> b) {
  final dx = a.x - b.x;
  final dy = a.y - b.y;
  return math.sqrt(dx * dx + dy * dy);
}

List<math.Point<double>> _normalizedPoints(
  Map<String, dynamic> normalized,
  int width,
  int height,
) {
  math.Point<double> point(String name) {
    final values = normalized[name] as Map<String, dynamic>;
    final x = ((values['x'] as num).toDouble().clamp(0.0, 1.0)) * (width - 1);
    final y = ((values['y'] as num).toDouble().clamp(0.0, 1.0)) * (height - 1);
    return math.Point(x, y);
  }

  return [
    point('topLeft'),
    point('topRight'),
    point('bottomRight'),
    point('bottomLeft')
  ];
}

/// Solves the homography which maps the unit output rectangle to [points].
List<double> _destinationToSourceHomography(List<math.Point<double>> points) {
  final matrix =
      List<List<double>>.generate(8, (row) => List<double>.filled(9, 0));
  const destination = [
    math.Point<double>(0, 0),
    math.Point<double>(1, 0),
    math.Point<double>(1, 1),
    math.Point<double>(0, 1),
  ];
  for (var index = 0; index < 4; index++) {
    final u = destination[index].x;
    final v = destination[index].y;
    final x = points[index].x;
    final y = points[index].y;
    matrix[index * 2] = [u, v, 1, 0, 0, 0, -u * x, -v * x, x];
    matrix[index * 2 + 1] = [0, 0, 0, u, v, 1, -u * y, -v * y, y];
  }
  for (var pivot = 0; pivot < 8; pivot++) {
    var bestRow = pivot;
    for (var row = pivot + 1; row < 8; row++) {
      if (matrix[row][pivot].abs() > matrix[bestRow][pivot].abs()) {
        bestRow = row;
      }
    }
    if (matrix[bestRow][pivot].abs() < 0.0000001) {
      throw const FormatException('Selected carton area is invalid');
    }
    final temporary = matrix[pivot];
    matrix[pivot] = matrix[bestRow];
    matrix[bestRow] = temporary;
    final divisor = matrix[pivot][pivot];
    for (var column = pivot; column <= 8; column++) {
      matrix[pivot][column] /= divisor;
    }
    for (var row = 0; row < 8; row++) {
      if (row == pivot) continue;
      final factor = matrix[row][pivot];
      for (var column = pivot; column <= 8; column++) {
        matrix[row][column] -= factor * matrix[pivot][column];
      }
    }
  }
  return [for (final row in matrix) row[8]];
}
