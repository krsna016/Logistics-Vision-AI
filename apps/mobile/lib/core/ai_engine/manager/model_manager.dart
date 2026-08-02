import 'dart:async';
import 'dart:typed_data';

import '../models/ai_model.dart';
import '../../../../utils/logger.dart';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';

class ModelManager {
  AIModel? _activeModel;
  OrtSession? _session;
  OrtSessionOptions? _sessionOptions;
  bool _envInitialized = false;
  Future<void> _lastRun = Future<void>.value();

  Future<void> loadModel(AIModel model) async {
    await unloadModel();
    OrtEnv.instance.init();
    _envInitialized = true;
    _sessionOptions = OrtSessionOptions()
      ..setIntraOpNumThreads(2)
      ..setInterOpNumThreads(1)
      ..setSessionGraphOptimizationLevel(GraphOptimizationLevel.ortEnableAll);
    final asset = await rootBundle.load(model.assetPath);
    _session =
        OrtSession.fromBuffer(asset.buffer.asUint8List(), _sessionOptions!);
    _activeModel = model;
    AppLogger.info(
        'Loaded ONNX model: ${model.name} v${model.version} (${_session!.inputNames} -> ${_session!.outputNames})');
  }

  Future<void> unloadModel() async {
    await _lastRun;
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
    final previousRun = _lastRun;
    final runComplete = Completer<void>();
    _lastRun = runComplete.future;
    await previousRun;

    final session = _session;
    if (session == null) {
      runComplete.complete();
      throw StateError('ONNX model is not loaded');
    }

    final inputOrt =
        OrtValueTensor.createTensorWithDataList(input, [1, 3, 640, 640]);
    final runOptions = OrtRunOptions();
    List<OrtValue?>? outputs;
    try {
      outputs = await session.runAsync(
            runOptions,
            {session.inputNames.first: inputOrt},
          ) ??
          const <OrtValue?>[];
      return outputs.isEmpty ? null : outputs.first?.value;
    } finally {
      outputs?.forEach((output) => output?.release());
      inputOrt.release();
      runOptions.release();
      runComplete.complete();
    }
  }
}
