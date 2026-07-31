import 'package:flutter/material.dart';

@immutable
class BoundingBox {
  /// Normalized coordinates between 0.0 and 1.0 relative to the source image dimensions.
  final double xMin;
  final double yMin;
  final double xMax;
  final double yMax;

  const BoundingBox({
    required this.xMin,
    required this.yMin,
    required this.xMax,
    required this.yMax,
  });

  /// Helper to convert normalized coordinate dimensions to absolute canvas size.
  Rect toAbsoluteRect(double width, double height) {
    return Rect.fromLTRB(
      xMin * width,
      yMin * height,
      xMax * width,
      yMax * height,
    );
  }
}

@immutable
class Detection {
  final String id;
  final BoundingBox boundingBox;
  final String label;
  final double confidence;
  final Color color;
  final String? trackingId;

  /// Extensibility hook for future computer vision layers (rotated boxes, keypoints, segmentation points).
  final Map<String, dynamic> metadata;

  const Detection({
    required this.id,
    required this.boundingBox,
    required this.label,
    required this.confidence,
    this.color = Colors.red,
    this.trackingId,
    this.metadata = const {},
  });

  Detection copyWith({
    String? id,
    BoundingBox? boundingBox,
    String? label,
    double? confidence,
    Color? color,
    String? trackingId,
    Map<String, dynamic>? metadata,
  }) {
    return Detection(
      id: id ?? this.id,
      boundingBox: boundingBox ?? this.boundingBox,
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      color: color ?? this.color,
      trackingId: trackingId ?? this.trackingId,
      metadata: metadata ?? this.metadata,
    );
  }
}
