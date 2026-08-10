import 'dart:math' as math;

import '../models/detection_result.dart';

/// Decodes Ultralytics YOLO segmentation output.
///
/// Supports both legacy YOLO-seg channel-first output and YOLO26 end-to-end
/// output. The deployed YOLO26 model emits [1, 300, 38] rows containing
/// x1/y1/x2/y2, confidence, class and 32 mask coefficients, plus
/// [1, 32, 160, 160] mask prototypes.
class Postprocessor {
  final double confidenceThreshold;
  final double iouThreshold;
  final int inputWidth;
  final int inputHeight;

  Postprocessor({
    this.confidenceThreshold = 0.27,
    this.iouThreshold = 0.70,
    this.inputWidth = 640,
    this.inputHeight = 640,
  });

  List<DetectionResult> process(
    List<dynamic> rawOutput, {
    required int imageWidth,
    required int imageHeight,
    bool decodeMasks = true,
    bool rotateLandscapeSensorToPortrait = false,
  }) {
    if (rawOutput.isEmpty) return [];

    final detectionRows = _endToEndRows(rawOutput.first);
    final detectionChannels =
        detectionRows == null ? _channels(rawOutput.first) : null;
    if (detectionRows != null) {
      return _processEndToEnd(
        detectionRows,
        rawOutput.length > 1 ? _channels(rawOutput[1]) : null,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        decodeMasks: decodeMasks,
        rotateLandscapeSensorToPortrait: rotateLandscapeSensorToPortrait,
      );
    }
    if (detectionChannels == null || detectionChannels.length < 5) return [];

    final prototypeChannels =
        rawOutput.length > 1 ? _channels(rawOutput[1]) : null;
    final candidateCount = _asList(detectionChannels[0])?.length ?? 0;
    if (candidateCount == 0) return [];

    final scale = math.min(inputWidth / imageWidth, inputHeight / imageHeight);
    final resizedWidth = (imageWidth * scale).round();
    final resizedHeight = (imageHeight * scale).round();
    final padX = ((inputWidth - resizedWidth) / 2.0 - 0.1).roundToDouble();
    final padY = ((inputHeight - resizedHeight) / 2.0 - 0.1).roundToDouble();
    final candidates = <_Candidate>[];

    for (var i = 0; i < candidateCount; i++) {
      final confidence = _numberAt(detectionChannels[4], i);
      final centerX = _numberAt(detectionChannels[0], i);
      final centerY = _numberAt(detectionChannels[1], i);
      final width = _numberAt(detectionChannels[2], i);
      final height = _numberAt(detectionChannels[3], i);
      if (confidence == null ||
          centerX == null ||
          centerY == null ||
          width == null ||
          height == null ||
          confidence < confidenceThreshold) {
        continue;
      }

      final left =
          ((centerX - width / 2.0 - padX) / scale / imageWidth).clamp(0.0, 1.0);
      final top = ((centerY - height / 2.0 - padY) / scale / imageHeight)
          .clamp(0.0, 1.0);
      final right =
          ((centerX + width / 2.0 - padX) / scale / imageWidth).clamp(0.0, 1.0);
      final bottom = ((centerY + height / 2.0 - padY) / scale / imageHeight)
          .clamp(0.0, 1.0);
      if (right <= left || bottom <= top) continue;

      final coefficients = <double>[];
      for (var channel = 5;
          channel < detectionChannels.length && channel < 37;
          channel++) {
        coefficients.add(_numberAt(detectionChannels[channel], i) ?? 0.0);
      }

      // Camera frames can arrive in landscape sensor coordinates while the
      // preview is portrait. Keep the mask in the same display coordinates
      // as the existing box conversion.
      final displayLeft = rotateLandscapeSensorToPortrait ? 1.0 - bottom : left;
      final displayTop = rotateLandscapeSensorToPortrait ? left : top;
      final displayRight = rotateLandscapeSensorToPortrait ? 1.0 - top : right;
      final displayBottom = rotateLandscapeSensorToPortrait ? right : bottom;
      candidates.add(_Candidate(
        id: 'carton_$i',
        confidence: confidence,
        left: displayLeft,
        top: displayTop,
        right: displayRight,
        bottom: displayBottom,
        sourceLeft: left,
        sourceTop: top,
        sourceRight: right,
        sourceBottom: bottom,
        coefficients: coefficients,
      ));
    }

    candidates.sort((a, b) => b.confidence.compareTo(a.confidence));
    final selected = <_Candidate>[];
    for (final candidate in candidates) {
      if (selected.every((other) => !_isDuplicate(candidate, other))) {
        selected.add(candidate);
      }
    }

    return selected.map((candidate) {
      final polygon = !decodeMasks || prototypeChannels == null
          ? const <List<double>>[]
          : _decodePolygon(
              candidate,
              prototypeChannels,
              imageWidth: imageWidth,
              imageHeight: imageHeight,
              scale: scale,
              padX: padX,
              padY: padY,
              rotateLandscapeSensorToPortrait: rotateLandscapeSensorToPortrait,
            );
      return DetectionResult(
        id: candidate.id,
        label: 'carton',
        confidence: candidate.confidence,
        xMin: candidate.left,
        yMin: candidate.top,
        xMax: candidate.right,
        yMax: candidate.bottom,
        polygon: polygon,
      );
    }).toList(growable: false);
  }

  List<DetectionResult> _processEndToEnd(
    List<List<dynamic>> rows,
    List<dynamic>? prototypeChannels, {
    required int imageWidth,
    required int imageHeight,
    required bool decodeMasks,
    required bool rotateLandscapeSensorToPortrait,
  }) {
    final scale = math.min(inputWidth / imageWidth, inputHeight / imageHeight);
    final resizedWidth = (imageWidth * scale).round();
    final resizedHeight = (imageHeight * scale).round();
    final padX = ((inputWidth - resizedWidth) / 2.0 - 0.1).roundToDouble();
    final padY = ((inputHeight - resizedHeight) / 2.0 - 0.1).roundToDouble();
    final candidates = <_Candidate>[];

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 38) continue;
      final leftInput = _numberAt(row, 0);
      final topInput = _numberAt(row, 1);
      final rightInput = _numberAt(row, 2);
      final bottomInput = _numberAt(row, 3);
      final confidence = _numberAt(row, 4);
      final classId = _numberAt(row, 5);
      if (leftInput == null ||
          topInput == null ||
          rightInput == null ||
          bottomInput == null ||
          confidence == null ||
          confidence < confidenceThreshold ||
          classId == null ||
          classId.round() != 0) {
        continue;
      }

      final left = ((leftInput - padX) / scale / imageWidth).clamp(0.0, 1.0);
      final top = ((topInput - padY) / scale / imageHeight).clamp(0.0, 1.0);
      final right = ((rightInput - padX) / scale / imageWidth).clamp(0.0, 1.0);
      final bottom =
          ((bottomInput - padY) / scale / imageHeight).clamp(0.0, 1.0);
      if (right <= left || bottom <= top) continue;

      final coefficients = <double>[
        for (var channel = 6; channel < 38; channel++)
          _numberAt(row, channel) ?? 0.0,
      ];
      candidates.add(_Candidate(
        id: 'carton_$i',
        confidence: confidence,
        left: rotateLandscapeSensorToPortrait ? 1.0 - bottom : left,
        top: rotateLandscapeSensorToPortrait ? left : top,
        right: rotateLandscapeSensorToPortrait ? 1.0 - top : right,
        bottom: rotateLandscapeSensorToPortrait ? right : bottom,
        sourceLeft: left,
        sourceTop: top,
        sourceRight: right,
        sourceBottom: bottom,
        coefficients: coefficients,
      ));
    }

    // YOLO26 export already performs NMS, but this guards against duplicate
    // rows without changing the benchmark's calibrated 0.70 IoU behavior.
    candidates.sort((a, b) => b.confidence.compareTo(a.confidence));
    final selected = <_Candidate>[];
    for (final candidate in candidates) {
      if (selected.every((other) => !_isDuplicate(candidate, other))) {
        selected.add(candidate);
      }
    }
    return selected.map((candidate) {
      final polygon = !decodeMasks || prototypeChannels == null
          ? const <List<double>>[]
          : _decodePolygon(
              candidate,
              prototypeChannels,
              imageWidth: imageWidth,
              imageHeight: imageHeight,
              scale: scale,
              padX: padX,
              padY: padY,
              rotateLandscapeSensorToPortrait: rotateLandscapeSensorToPortrait,
            );
      return DetectionResult(
        id: candidate.id,
        label: 'carton',
        confidence: candidate.confidence,
        xMin: candidate.left,
        yMin: candidate.top,
        xMax: candidate.right,
        yMax: candidate.bottom,
        polygon: polygon,
      );
    }).toList(growable: false);
  }

  List<List<dynamic>>? _endToEndRows(dynamic output) {
    final batch = _asList(output);
    if (batch == null || batch.length != 1) return null;
    final rows = _asList(batch.first);
    if (rows == null || rows.isEmpty) return null;
    final first = _asList(rows.first);
    if (first == null || first.length != 38) return null;
    return rows.map(_asList).whereType<List<dynamic>>().toList(growable: false);
  }

  List<List<double>> _decodePolygon(
    _Candidate candidate,
    List<dynamic> prototypes, {
    required int imageWidth,
    required int imageHeight,
    required double scale,
    required double padX,
    required double padY,
    required bool rotateLandscapeSensorToPortrait,
  }) {
    final prototypeWidth = _asList(prototypes.firstOrNull)?.length ?? 0;
    final prototypeHeight =
        _asList(_asList(prototypes.firstOrNull)?.firstOrNull)?.length ?? 0;
    if (prototypes.length < 3 || prototypeWidth == 0 || prototypeHeight == 0) {
      return const [];
    }

    final maskWidth = prototypeWidth;
    final maskHeight = prototypeHeight;
    final xMinInput = candidate.sourceLeft * imageWidth * scale + padX;
    final yMinInput = candidate.sourceTop * imageHeight * scale + padY;
    final xMaxInput = candidate.sourceRight * imageWidth * scale + padX;
    final yMaxInput = candidate.sourceBottom * imageHeight * scale + padY;
    final xMin =
        (xMinInput / inputWidth * maskWidth).floor().clamp(0, maskWidth - 1);
    final yMin =
        (yMinInput / inputHeight * maskHeight).floor().clamp(0, maskHeight - 1);
    final xMax =
        (xMaxInput / inputWidth * maskWidth).ceil().clamp(xMin + 1, maskWidth);
    final yMax = (yMaxInput / inputHeight * maskHeight)
        .ceil()
        .clamp(yMin + 1, maskHeight);

    final cropWidth = xMax - xMin;
    final cropHeight = yMax - yMin;
    final logits = List<double>.filled(cropWidth * cropHeight, -30.0);
    for (var y = yMin; y < yMax; y++) {
      for (var x = xMin; x < xMax; x++) {
        var logit = 0.0;
        for (var channel = 0;
            channel < candidate.coefficients.length &&
                channel < prototypes.length;
            channel++) {
          final row = _asList(prototypes[channel]);
          final values = row == null ? null : _asList(row[y]);
          final value = values == null ? null : _numberAt(values, x);
          if (value != null) logit += candidate.coefficients[channel] * value;
        }
        // A sigmoid probability of 0.5 is exactly logit 0. Retaining the
        // continuous logits lets marching squares interpolate that boundary
        // between prototype samples, matching a bilinearly enlarged mask.
        logits[(y - yMin) * cropWidth + (x - xMin)] = logit.clamp(-30.0, 30.0);
      }
    }

    final contour = _traceProbabilityContour(
      logits,
      cropWidth: cropWidth,
      cropHeight: cropHeight,
      offsetX: xMin,
      offsetY: yMin,
    );
    if (contour.length < 3) return const [];

    // The contour is already sub-pixel accurate. Use a light tolerance only
    // to remove redundant points; carton corners and perspective remain.
    final simplified = _simplifyClosedContour(contour, tolerance: 0.18);
    return simplified
        .map((point) => _toDisplayPoint(
              point[0],
              point[1],
              maskWidth,
              maskHeight,
              imageWidth,
              imageHeight,
              scale,
              padX,
              padY,
              rotateLandscapeSensorToPortrait,
            ))
        .toList(growable: false);
  }

  List<List<double>> _traceProbabilityContour(
    List<double> logits, {
    required int cropWidth,
    required int cropHeight,
    required int offsetX,
    required int offsetY,
  }) {
    if (cropWidth == 0 ||
        cropHeight == 0 ||
        !logits.any((value) => value >= 0)) {
      return const [];
    }

    // One negative sample around the cropped mask closes contours that touch
    // a detection box, just as Ultralytics crops masks outside their boxes.
    final gridWidth = cropWidth + 2;
    final gridHeight = cropHeight + 2;
    final grid = List<double>.filled(gridWidth * gridHeight, -30.0);
    for (var y = 0; y < cropHeight; y++) {
      for (var x = 0; x < cropWidth; x++) {
        grid[(y + 1) * gridWidth + x + 1] = logits[y * cropWidth + x];
      }
    }

    final horizontalCount = gridHeight * (gridWidth - 1);
    final nodeCount = horizontalCount + (gridHeight - 1) * gridWidth;
    final adjacency = <int, List<int>>{};
    final points = <int, List<double>>{};

    int horizontal(int x, int y) => y * (gridWidth - 1) + x;
    int vertical(int x, int y) => horizontalCount + y * gridWidth + x;
    double value(int x, int y) => grid[y * gridWidth + x];
    List<double> samplePoint(double x, double y) => <double>[
          offsetX + x - 0.5,
          offsetY + y - 0.5,
        ];
    double crossing(double first, double second) {
      final denominator = first - second;
      if (denominator.abs() < 1e-9) return 0.5;
      return (first / denominator).clamp(0.0, 1.0);
    }

    int edgeNode(int edge, int x, int y) {
      final topLeft = value(x, y);
      final topRight = value(x + 1, y);
      final bottomRight = value(x + 1, y + 1);
      final bottomLeft = value(x, y + 1);
      late final int node;
      late final List<double> point;
      switch (edge) {
        case 0:
          node = horizontal(x, y);
          point = samplePoint(x + crossing(topLeft, topRight), y.toDouble());
        case 1:
          node = vertical(x + 1, y);
          point = samplePoint(
            (x + 1).toDouble(),
            y + crossing(topRight, bottomRight),
          );
        case 2:
          node = horizontal(x, y + 1);
          point = samplePoint(
            x + crossing(bottomLeft, bottomRight),
            (y + 1).toDouble(),
          );
        case 3:
          node = vertical(x, y);
          point = samplePoint(
            x.toDouble(),
            y + crossing(topLeft, bottomLeft),
          );
        default:
          throw RangeError.range(edge, 0, 3);
      }
      points[node] = point;
      return node;
    }

    void connect(int firstEdge, int secondEdge, int x, int y) {
      final first = edgeNode(firstEdge, x, y);
      final second = edgeNode(secondEdge, x, y);
      adjacency.putIfAbsent(first, () => <int>[]).add(second);
      adjacency.putIfAbsent(second, () => <int>[]).add(first);
    }

    for (var y = 0; y < gridHeight - 1; y++) {
      for (var x = 0; x < gridWidth - 1; x++) {
        final topLeft = value(x, y) >= 0 ? 1 : 0;
        final topRight = value(x + 1, y) >= 0 ? 2 : 0;
        final bottomRight = value(x + 1, y + 1) >= 0 ? 4 : 0;
        final bottomLeft = value(x, y + 1) >= 0 ? 8 : 0;
        final maskCase = topLeft | topRight | bottomRight | bottomLeft;
        switch (maskCase) {
          case 1:
          case 14:
            connect(3, 0, x, y);
          case 2:
          case 13:
            connect(0, 1, x, y);
          case 3:
          case 12:
            connect(3, 1, x, y);
          case 4:
          case 11:
            connect(1, 2, x, y);
          case 6:
          case 9:
            connect(0, 2, x, y);
          case 7:
          case 8:
            connect(3, 2, x, y);
          case 5:
            final center = (value(x, y) +
                    value(x + 1, y) +
                    value(x + 1, y + 1) +
                    value(x, y + 1)) /
                4.0;
            if (center >= 0) {
              connect(0, 1, x, y);
              connect(2, 3, x, y);
            } else {
              connect(3, 0, x, y);
              connect(1, 2, x, y);
            }
          case 10:
            final center = (value(x, y) +
                    value(x + 1, y) +
                    value(x + 1, y + 1) +
                    value(x, y + 1)) /
                4.0;
            if (center >= 0) {
              connect(3, 0, x, y);
              connect(1, 2, x, y);
            } else {
              connect(0, 1, x, y);
              connect(2, 3, x, y);
            }
        }
      }
    }

    final visitedEdges = <int>{};
    var best = const <List<double>>[];
    var bestArea = 0.0;
    int edgeKey(int first, int second) {
      final low = math.min(first, second);
      final high = math.max(first, second);
      return low * nodeCount + high;
    }

    for (final entry in adjacency.entries) {
      for (final firstNeighbour in entry.value) {
        if (visitedEdges.contains(edgeKey(entry.key, firstNeighbour))) continue;
        final loop = <List<double>>[];
        final start = entry.key;
        var previous = -1;
        var current = start;
        while (true) {
          final point = points[current];
          if (point == null) break;
          loop.add(point);
          final neighbours = adjacency[current] ?? const <int>[];
          final next = neighbours.where((candidate) {
            if (candidate == previous && neighbours.length > 1) return false;
            return !visitedEdges.contains(edgeKey(current, candidate)) ||
                candidate == start;
          }).firstOrNull;
          if (next == null) break;
          visitedEdges.add(edgeKey(current, next));
          previous = current;
          current = next;
          if (current == start) break;
        }
        if (current != start || loop.length < 3) continue;
        final area = _polygonArea(loop).abs();
        if (area > bestArea) {
          bestArea = area;
          best = loop;
        }
      }
    }
    return best;
  }

  double _polygonArea(List<List<double>> points) {
    var area = 0.0;
    for (var i = 0; i < points.length; i++) {
      final next = points[(i + 1) % points.length];
      area += points[i][0] * next[1] - next[0] * points[i][1];
    }
    return area / 2.0;
  }

  List<List<double>> _simplifyClosedContour(
    List<List<double>> points, {
    required double tolerance,
  }) {
    if (points.length < 6) return points;
    var split = 1;
    var farthest = -1.0;
    for (var i = 1; i < points.length; i++) {
      final dx = points[i][0] - points[0][0];
      final dy = points[i][1] - points[0][1];
      final distance = dx * dx + dy * dy;
      if (distance > farthest) {
        farthest = distance;
        split = i;
      }
    }
    final first = _rdp(points.sublist(0, split + 1), tolerance);
    final second = _rdp(
      <List<double>>[...points.sublist(split), points.first],
      tolerance,
    );
    return <List<double>>[
      ...first.take(first.length - 1),
      ...second.take(second.length - 1),
    ];
  }

  List<List<double>> _rdp(List<List<double>> points, double tolerance) {
    if (points.length <= 2) return points;
    var index = 0;
    var maximum = 0.0;
    for (var i = 1; i < points.length - 1; i++) {
      final distance = _distanceToSegment(points[i], points.first, points.last);
      if (distance > maximum) {
        maximum = distance;
        index = i;
      }
    }
    if (maximum <= tolerance) return <List<double>>[points.first, points.last];
    final left = _rdp(points.sublist(0, index + 1), tolerance);
    final right = _rdp(points.sublist(index), tolerance);
    return <List<double>>[...left.take(left.length - 1), ...right];
  }

  double _distanceToSegment(
    List<double> point,
    List<double> start,
    List<double> end,
  ) {
    final dx = end[0] - start[0];
    final dy = end[1] - start[1];
    if (dx == 0 && dy == 0) {
      return math.sqrt(
          math.pow(point[0] - start[0], 2) + math.pow(point[1] - start[1], 2));
    }
    final t = (((point[0] - start[0]) * dx + (point[1] - start[1]) * dy) /
            (dx * dx + dy * dy))
        .clamp(0.0, 1.0);
    final nearestX = start[0] + t * dx;
    final nearestY = start[1] + t * dy;
    return math.sqrt(
        math.pow(point[0] - nearestX, 2) + math.pow(point[1] - nearestY, 2));
  }

  List<double> _toDisplayPoint(
    double x,
    double y,
    int maskWidth,
    int maskHeight,
    int imageWidth,
    int imageHeight,
    double scale,
    double padX,
    double padY,
    bool rotateLandscapeSensorToPortrait,
  ) {
    final inputX = x / maskWidth * inputWidth;
    final inputY = y / maskHeight * inputHeight;
    final sourceX = ((inputX - padX) / scale / imageWidth).clamp(0.0, 1.0);
    final sourceY = ((inputY - padY) / scale / imageHeight).clamp(0.0, 1.0);
    return rotateLandscapeSensorToPortrait
        ? [1.0 - sourceY, sourceX]
        : [sourceX, sourceY];
  }

  List<dynamic>? _channels(dynamic output) {
    var value = output;
    final outer = _asList(value);
    if (outer == null || outer.isEmpty) return null;
    if (outer.length == 1 && _asList(outer.first) != null) value = outer.first;
    return _asList(value);
  }

  List<dynamic>? _asList(dynamic value) {
    if (value is List) return value.cast<dynamic>();
    // Some ONNX/runtime versions expose tensor dimensions as an Iterable
    // rather than a literal List. Normalize both forms before decoding.
    if (value is Iterable) return value.toList(growable: false);
    return null;
  }

  double? _numberAt(dynamic values, int index) {
    final list = _asList(values);
    if (list == null || index < 0 || index >= list.length) return null;
    final value = list[index];
    return value is num ? value.toDouble() : null;
  }

  bool _isDuplicate(_Candidate first, _Candidate second) {
    // Match the calibrated benchmark exactly. Nearby centres and partial
    // overlap are normal in dense, perspective-distorted carton layers and
    // must not be treated as duplicate detections.
    return _iou(first, second) >= iouThreshold;
  }

  double _iou(_Candidate a, _Candidate b) {
    final left = math.max(a.left, b.left);
    final top = math.max(a.top, b.top);
    final right = math.min(a.right, b.right);
    final bottom = math.min(a.bottom, b.bottom);
    final intersection =
        math.max(0.0, right - left) * math.max(0.0, bottom - top);
    final areaA = (a.right - a.left) * (a.bottom - a.top);
    final areaB = (b.right - b.left) * (b.bottom - b.top);
    final union = areaA + areaB - intersection;
    return union <= 0 ? 0 : intersection / union;
  }
}

class _Candidate {
  final String id;
  final double confidence;
  final double left, top, right, bottom;
  final double sourceLeft, sourceTop, sourceRight, sourceBottom;
  final List<double> coefficients;

  const _Candidate({
    required this.id,
    required this.confidence,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.sourceLeft,
    required this.sourceTop,
    required this.sourceRight,
    required this.sourceBottom,
    required this.coefficients,
  });
}
