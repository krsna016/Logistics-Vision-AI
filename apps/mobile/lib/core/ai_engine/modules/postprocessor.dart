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

  Postprocessor({
    this.confidenceThreshold = 0.27,
    this.iouThreshold = 0.70,
  });

  List<DetectionResult> process(
    List<dynamic> rawOutput, {
    required int imageWidth,
    required int imageHeight,
    bool decodeMasks = true,
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
      );
    }
    if (detectionChannels == null || detectionChannels.length < 5) return [];

    final prototypeChannels =
        rawOutput.length > 1 ? _channels(rawOutput[1]) : null;
    final candidateCount = _asList(detectionChannels[0])?.length ?? 0;
    if (candidateCount == 0) return [];

    final scale = math.min(640.0 / imageWidth, 640.0 / imageHeight);
    final resizedWidth = imageWidth * scale;
    final resizedHeight = imageHeight * scale;
    final padX = (640.0 - resizedWidth) / 2.0;
    final padY = (640.0 - resizedHeight) / 2.0;
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
      final displayLeft = imageWidth > imageHeight ? 1.0 - bottom : left;
      final displayTop = imageWidth > imageHeight ? left : top;
      final displayRight = imageWidth > imageHeight ? 1.0 - top : right;
      final displayBottom = imageWidth > imageHeight ? right : bottom;
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
  }) {
    final scale = math.min(640.0 / imageWidth, 640.0 / imageHeight);
    final padX = (640.0 - imageWidth * scale) / 2.0;
    final padY = (640.0 - imageHeight * scale) / 2.0;
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
        left: imageWidth > imageHeight ? 1.0 - bottom : left,
        top: imageWidth > imageHeight ? left : top,
        right: imageWidth > imageHeight ? 1.0 - top : right,
        bottom: imageWidth > imageHeight ? right : bottom,
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
        (xMinInput / 640.0 * maskWidth).floor().clamp(0, maskWidth - 1);
    final yMin =
        (yMinInput / 640.0 * maskHeight).floor().clamp(0, maskHeight - 1);
    final xMax =
        (xMaxInput / 640.0 * maskWidth).ceil().clamp(xMin + 1, maskWidth);
    final yMax =
        (yMaxInput / 640.0 * maskHeight).ceil().clamp(yMin + 1, maskHeight);

    final leftEdge = <List<double>>[];
    final rightEdge = <List<double>>[];
    for (var y = yMin; y < yMax; y++) {
      var first = -1;
      var last = -1;
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
        final probability = 1.0 / (1.0 + math.exp(-logit.clamp(-30.0, 30.0)));
        if (probability >= 0.5) {
          first = first < 0 ? x : first;
          last = x;
        }
      }
      if (first >= 0) {
        leftEdge.add(_toDisplayPoint(first, y, maskWidth, maskHeight,
            imageWidth, imageHeight, scale, padX, padY));
        rightEdge.add(_toDisplayPoint(last, y, maskWidth, maskHeight,
            imageWidth, imageHeight, scale, padX, padY));
      }
    }
    if (leftEdge.length < 2) return const [];

    final points = <List<double>>[...leftEdge, ...rightEdge.reversed];
    if (points.length <= 96) return points;
    final step = points.length / 96.0;
    return [for (var i = 0; i < 96; i++) points[(i * step).floor()]];
  }

  List<double> _toDisplayPoint(
    int x,
    int y,
    int maskWidth,
    int maskHeight,
    int imageWidth,
    int imageHeight,
    double scale,
    double padX,
    double padY,
  ) {
    final inputX = (x + 0.5) / maskWidth * 640.0;
    final inputY = (y + 0.5) / maskHeight * 640.0;
    final sourceX = ((inputX - padX) / scale / imageWidth).clamp(0.0, 1.0);
    final sourceY = ((inputY - padY) / scale / imageHeight).clamp(0.0, 1.0);
    return imageWidth > imageHeight
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
