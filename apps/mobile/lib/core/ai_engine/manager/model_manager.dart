import '../models/ai_model.dart';
import '../../../../utils/logger.dart';

class ModelManager {
  AIModel? _activeModel;

  Future<void> loadModel(AIModel model) async {
    // In production, this loads the specific ONNX file from assets/documents
    // and binds it to the C++ runtime.
    _activeModel = model;
    AppLogger.info('Loaded AI Model: ${model.name} v${model.version}');
  }

  Future<void> unloadModel() async {
    _activeModel = null;
    AppLogger.info('Unloaded AI Model');
  }

  Future<void> replaceModel(AIModel newModel) async {
    await unloadModel();
    await loadModel(newModel);
  }

  AIModel? get activeModel => _activeModel;
}
