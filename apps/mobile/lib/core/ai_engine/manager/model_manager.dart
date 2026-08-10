import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

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
  Future<void>? _loadInProgress;

  Future<void> loadModel(AIModel model) async {
    if (_session != null && _activeModel?.id == model.id) return;
    final existingLoad = _loadInProgress;
    if (existingLoad != null) return existingLoad;

    final load = _loadAssetModel(model);
    _loadInProgress = load;
    try {
      await load;
    } finally {
      if (identical(_loadInProgress, load)) _loadInProgress = null;
    }
  }

  Future<void> _loadAssetModel(AIModel model) async {
    await unloadModel();
    final totalWatch = Stopwatch()..start();
    final assetWatch = Stopwatch()..start();
    final asset = await rootBundle.load(model.assetPath);
    assetWatch.stop();
    await _loadBytes(asset.buffer.asUint8List(), model);
    totalWatch.stop();
    AppLogger.info(
      'Model startup timings: asset=${assetWatch.elapsedMilliseconds}ms, '
      'total=${totalWatch.elapsedMilliseconds}ms',
    );
  }

  Future<void> loadModelFromPath(String path, {AIModel? metadata}) async {
    await unloadModel();
    await _loadBytes(
        await File(path).readAsBytes(), metadata ?? AIModel.modelB());
  }

  Future<void> _loadBytes(Uint8List bytes, AIModel model) async {
    final integrityWatch = Stopwatch()..start();
    final actualSha256 = sha256.convert(bytes).toString();
    integrityWatch.stop();
    if (model.expectedSha256.isNotEmpty &&
        actualSha256 != model.expectedSha256) {
      throw StateError(
        'Model integrity verification failed for ${model.assetPath}',
      );
    }
    final sessionWatch = Stopwatch()..start();
    OrtEnv.instance.init();
    _envInitialized = true;
    _sessionOptions = OrtSessionOptions()
      ..setIntraOpNumThreads(2)
      ..setInterOpNumThreads(1)
      ..setSessionGraphOptimizationLevel(GraphOptimizationLevel.ortEnableAll);
    _session = OrtSession.fromBuffer(bytes, _sessionOptions!);
    sessionWatch.stop();
    _activeModel = model;
    AppLogger.info(
      'Loaded ONNX model: ${model.name} v${model.version} '
      '(${_session!.inputNames} -> ${_session!.outputNames}); '
      'integrity=${integrityWatch.elapsedMilliseconds}ms, '
      'session=${sessionWatch.elapsedMilliseconds}ms',
    );
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
      // Segmentation exports have two outputs: detections and mask
      // prototypes. Keep both; dropping the second output silently turns a
      // segmentation model into a box-only detector.
      return outputs.map((output) => output?.value).toList(growable: false);
    } finally {
      outputs?.forEach((output) => output?.release());
      inputOrt.release();
      runOptions.release();
      runComplete.complete();
    }
  }
}
