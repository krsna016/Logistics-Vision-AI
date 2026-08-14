class AIModel {
  static const activeLabel = 'YOLO26m Seg · Stage 1';
  static const activeVersion = 'yolo26m_carton_seg_stage1_v1';
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
  final String expectedSha256;

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
    required this.expectedSha256,
  });

  factory AIModel.modelB() {
    return AIModel(
      id: activeVersion,
      name: 'YOLO26m Stage 1 Carton Segmentation Model',
      version: '1.0.0',
      trainingDate: DateTime(2026, 8, 9),
      deploymentDate: DateTime(2026, 8, 10),
      inputWidth: 960,
      inputHeight: 960,
      outputClasses: const ['carton'],
      expectedMap: 0.98290,
      expectedPrecision: 0.95921,
      expectedRecall: 0.94627,
      assetPath: 'assets/models/stage1_carton_yolo26m_seg_960.onnx',
      expectedSha256:
          '935a736845b1921b554174723b5b3d1c9e477e5235e41734e882374356008bc7',
      developerNotes:
          'Stage 1 YOLO26m instance-segmentation checkpoint exported to ONNX at 960 px. Metrics are final-epoch internal validation mask metrics (mAP50 0.98290, precision 0.95921, recall 0.94627), not independent warehouse acceptance results. Counting threshold: 0.27.',
    );
  }
}
