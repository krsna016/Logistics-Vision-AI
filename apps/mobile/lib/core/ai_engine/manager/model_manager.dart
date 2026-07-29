import '../models/ai_model.dart';
import '../../../../utils/logger.dart';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'dart:typed_data';

class ModelManager {
  AIModel? _activeModel;
  OrtSession? _session;
  OrtSessionOptions? _sessionOptions;
  bool _envInitialized = false;

  Future<void> loadModel(AIModel model) async {
    await unloadModel();
    OrtEnv.instance.init();
    _envInitialized = true;
    _sessionOptions = OrtSessionOptions()
      ..setIntraOpNumThreads(2)
      ..setInterOpNumThreads(1)
      ..setSessionGraphOptimizationLevel(GraphOptimizationLevel.ortEnableAll);
    final asset = await rootBundle.load(model.assetPath);
    _session = OrtSession.fromBuffer(asset.buffer.asUint8List(), _sessionOptions!);
    _activeModel = model;
    AppLogger.info('Loaded ONNX model: ${model.name} v${model.version} (${_session!.inputNames} -> ${_session!.outputNames})');
  }

  Future<void> unloadModel() async {
    _session?.release();
    _session = null;
    _sessionOptions?.release();
    _sessionOptions = null;
    _activeModel = null;
    if (_envInitialized) {
      OrtEnv.instance.release();
      _envInitialized = false;
    }
    AppLogger.info('Unloaded AI model');
  }

  Future<void> replaceModel(AIModel newModel) async {
    await unloadModel();
    await loadModel(newModel);
  }

  AIModel? get activeModel => _activeModel;
  OrtSession? get session => _session;

  Future<dynamic> run(Float32List input) async {
    final session = _session;
    if (session == null) throw StateError('ONNX model is not loaded');
    final inputOrt = OrtValueTensor.createTensorWithDataList(input, [1, 3, 640, 640]);
    final runOptions = OrtRunOptions();
    try {
      final outputs = await session.runAsync(
        runOptions,
        {session.inputNames.first: inputOrt},
      ) ?? const <OrtValue?>[];
      return outputs.isEmpty ? null : outputs.first?.value;
    } finally {
      inputOrt.release();
      runOptions.release();
    }
  }
}
