import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import '../models/ai_model.dart';
import '../../../../utils/logger.dart';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';

class ModelManager {
  AIModel? _activeModel;
  OrtSession? _session;
  _OwnedSessionIsolate? _sessionOwner;
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
    // The worker owns expensive integrity verification and native ONNX graph
    // construction. Only the lightweight pointer wrapper is created here.
    final ownedSession = await _OwnedSessionIsolate.create(
      bytes: bytes,
      expectedSha256: model.expectedSha256,
    );
    OrtEnv.instance.init();
    _envInitialized = true;
    try {
      _session = OrtSession.fromAddress(ownedSession.sessionAddress);
      _sessionOwner = ownedSession;
    } catch (_) {
      await ownedSession.dispose(releaseSession: true);
      rethrow;
    }
    _activeModel = model;
    AppLogger.info(
      'Loaded ONNX model: ${model.name} v${model.version} '
      '(${_session!.inputNames} -> ${_session!.outputNames}); '
      'integrity=${ownedSession.integrityMs}ms, '
      'session=${ownedSession.sessionMs}ms (background worker)',
    );
  }

  Future<void> unloadModel() async {
    await _lastRun;
    _session?.release();
    _session = null;
    _activeModel = null;
    if (_envInitialized) {
      OrtEnv.instance.release();
      _envInitialized = false;
    }
    await _sessionOwner?.dispose();
    _sessionOwner = null;
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

class _OwnedSessionIsolate {
  final Isolate _isolate;
  final SendPort _controlPort;
  final int sessionAddress;
  final int integrityMs;
  final int sessionMs;

  const _OwnedSessionIsolate._({
    required Isolate isolate,
    required SendPort controlPort,
    required this.sessionAddress,
    required this.integrityMs,
    required this.sessionMs,
  })  : _isolate = isolate,
        _controlPort = controlPort;

  static Future<_OwnedSessionIsolate> create({
    required Uint8List bytes,
    required String expectedSha256,
  }) async {
    final replies = ReceivePort();
    final errors = ReceivePort();
    final isolate = await Isolate.spawn<Map<String, Object?>>(
      _createOwnedOnnxSession,
      <String, Object?>{
        'replyPort': replies.sendPort,
        'bytes': TransferableTypedData.fromList(<Uint8List>[bytes]),
        'expectedSha256': expectedSha256,
      },
      debugName: 'SmartLoadAiRuntimeInitializer',
      onError: errors.sendPort,
    );

    try {
      final response = await Future.any<Object?>(<Future<Object?>>[
        replies.first,
        errors.first,
      ]);
      if (response is! Map) {
        throw StateError('AI runtime worker stopped unexpectedly: $response');
      }
      if (response['error'] != null) {
        throw StateError('${response['error']}');
      }
      return _OwnedSessionIsolate._(
        isolate: isolate,
        controlPort: response['controlPort']! as SendPort,
        sessionAddress: response['sessionAddress']! as int,
        integrityMs: response['integrityMs']! as int,
        sessionMs: response['sessionMs']! as int,
      );
    } catch (_) {
      isolate.kill(priority: Isolate.immediate);
      rethrow;
    } finally {
      replies.close();
      errors.close();
    }
  }

  Future<void> dispose({bool releaseSession = false}) async {
    final reply = ReceivePort();
    _controlPort.send(<String, Object?>{
      'replyPort': reply.sendPort,
      'releaseSession': releaseSession,
    });
    try {
      await reply.first.timeout(const Duration(seconds: 2));
    } catch (_) {
      // The native session has already been released by the main owner during
      // normal shutdown; a dead worker can be terminated safely here.
    } finally {
      reply.close();
      _isolate.kill(priority: Isolate.immediate);
    }
  }
}

Future<void> _createOwnedOnnxSession(Map<String, Object?> message) async {
  final replyPort = message['replyPort']! as SendPort;
  OrtSession? session;
  OrtSessionOptions? options;
  try {
    final transferable = message['bytes']! as TransferableTypedData;
    final bytes = transferable.materialize().asUint8List();
    final integrityWatch = Stopwatch()..start();
    final actualSha256 = sha256.convert(bytes).toString();
    integrityWatch.stop();
    final expectedSha256 = message['expectedSha256']! as String;
    if (expectedSha256.isNotEmpty && actualSha256 != expectedSha256) {
      throw StateError('Model integrity verification failed.');
    }

    final sessionWatch = Stopwatch()..start();
    OrtEnv.instance.init();
    options = OrtSessionOptions()
      ..setIntraOpNumThreads(2)
      ..setInterOpNumThreads(1)
      ..setSessionGraphOptimizationLevel(GraphOptimizationLevel.ortEnableAll);
    session = OrtSession.fromBuffer(bytes, options);
    options.release();
    options = null;
    sessionWatch.stop();

    final controls = ReceivePort();
    replyPort.send(<String, Object?>{
      'sessionAddress': session.address,
      'integrityMs': integrityWatch.elapsedMilliseconds,
      'sessionMs': sessionWatch.elapsedMilliseconds,
      'controlPort': controls.sendPort,
    });

    await for (final command in controls) {
      if (command is! Map) continue;
      final commandReply = command['replyPort'] as SendPort?;
      if (command['releaseSession'] == true) session.release();
      OrtEnv.instance.release();
      commandReply?.send(true);
      controls.close();
      return;
    }
  } catch (error, stack) {
    options?.release();
    session?.release();
    OrtEnv.instance.release();
    replyPort.send(<String, Object?>{
      'error': error.toString(),
      'stack': stack.toString(),
    });
  }
}
