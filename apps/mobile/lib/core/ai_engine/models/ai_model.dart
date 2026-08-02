class AIModel {
  static const activeLabel = 'YOLO11n Seg';
  static const activeVersion = 'yolo11n_carton_seg_v1_3';
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

  factory AIModel.modelB() {
    return AIModel(
      id: activeVersion,
      name: 'YOLO11n Carton Segmentation Model',
      version: '1.3.0',
      trainingDate: DateTime(2026, 8, 1),
      deploymentDate: DateTime(2026, 8, 2),
      inputWidth: 640,
      inputHeight: 640,
      outputClasses: const ['carton'],
      expectedMap: 0.983,
      expectedPrecision: 0.97,
      expectedRecall: 0.95,
      assetPath: 'assets/models/carton_model_b.onnx',
      developerNotes:
          'Model B: YOLO11n instance-segmentation model trained for carton counting.',
    );
  }
}
