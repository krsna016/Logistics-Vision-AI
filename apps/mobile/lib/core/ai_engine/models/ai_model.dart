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
  final String assetPath;

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
    required this.assetPath,
  });

  factory AIModel.yolo11n() {
    return AIModel(
      id: 'yolo11n_carton_v1',
      name: 'YOLO11n Carton Detector',
      version: '1.0.0',
      trainingDate: DateTime(2026, 6, 1),
      deploymentDate: DateTime(2026, 7, 1),
      inputWidth: 640,
      inputHeight: 640,
      outputClasses: const ['carton'],
      expectedMap: 0.995,
      expectedPrecision: 1.0,
      expectedRecall: 1.0,
      assetPath: 'assets/models/carton_yolo11n.onnx',
      developerNotes: 'Validated YOLO11n carton detector exported to ONNX.',
    );
  }
}
