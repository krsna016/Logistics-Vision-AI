class AIModel {
  final String id;
  final String name;
  final String version;
  final DateTime trainingDate;
  final DateTime deploymentDate;
  final int inputWidth;
  final int inputHeight;
  final List<String> outputClasses;
  final double expectedMap;
  final double expectedPrecision;
  final double expectedRecall;
  final String developerNotes;

  const AIModel({
    required this.id,
    required this.name,
    required this.version,
    required this.trainingDate,
    required this.deploymentDate,
    required this.inputWidth,
    required this.inputHeight,
    required this.outputClasses,
    required this.expectedMap,
    required this.expectedPrecision,
    required this.expectedRecall,
    this.developerNotes = '',
  });

  factory AIModel.yolo11s() {
    return AIModel(
      id: 'yolo11s_v1',
      name: 'YOLO11s',
      version: '1.0.0',
      trainingDate: DateTime(2026, 6, 1),
      deploymentDate: DateTime(2026, 7, 1),
      inputWidth: 640,
      inputHeight: 640,
      outputClasses: const ['carton'],
      expectedMap: 0.92,
      expectedPrecision: 0.94,
      expectedRecall: 0.90,
      developerNotes: 'Standard YOLO11s optimized for edge.',
    );
  }
}
