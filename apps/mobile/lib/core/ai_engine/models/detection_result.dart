class DetectionResult {
  final String id;
  final String label;
  final double confidence;
  final double xMin;
  final double yMin;
  final double xMax;
  final double yMax;

  const DetectionResult({
    required this.id,
    required this.label,
    required this.confidence,
    required this.xMin,
    required this.yMin,
    required this.xMax,
    required this.yMax,
  });
}
