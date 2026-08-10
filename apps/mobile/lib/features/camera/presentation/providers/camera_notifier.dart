import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';

import '../../domain/repositories/camera_repository.dart';
import '../../data/repositories_impl/camera_repository_impl.dart';
import 'camera_state.dart';
import '../../../../utils/logger.dart';

// Android camera release is asynchronous. A new provider can be created on a
// later route before the previous provider has finished closing the hardware,
// so serialize release and initialization across provider lifetimes.
Future<void> _pendingCameraRelease = Future<void>.value();

// Provider pointing to the concrete repository implementation
final cameraRepositoryProvider = Provider<CameraRepository>((ref) {
  return CameraRepositoryImpl();
});

// StateNotifierProvider that exposes the camera controller state
final cameraNotifierProvider =
    StateNotifierProvider.autoDispose<CameraNotifier, CameraState>((ref) {
  final repository = ref.watch(cameraRepositoryProvider);
  final notifier = CameraNotifier(repository);

  // Clean up when provider is disposed
  ref.onDispose(() {
    notifier.disposeCamera();
  });

  return notifier;
});

class CameraNotifier extends StateNotifier<CameraState>
    with WidgetsBindingObserver {
  final CameraRepository _repository;
  int _cameraOperation = 0;
  Timer? _reconnectTimer;
  bool _isRecovering = false;
  int _consecutiveRecoveries = 0;
  int _initializationFailures = 0;
  AppLifecycleState _lifecycleState =
      WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;

  CameraNotifier(this._repository)
      : super(const CameraState(status: CameraStatus.initializing)) {
    WidgetsBinding.instance.addObserver(this);
    initialize();
  }

  Future<void> initialize() async {
    final existingController = state.controller;
    if (state.status == CameraStatus.ready &&
        existingController?.value.isInitialized == true) {
      return;
    }

    final operation = ++_cameraOperation;
    final startupWatch = Stopwatch()..start();
    _reconnectTimer?.cancel();
    state = const CameraState(status: CameraStatus.initializing);
    try {
      await _pendingCameraRelease;
      if (!mounted || operation != _cameraOperation) return;

      final hasPermission = await _repository.requestCameraPermission();
      if (!mounted || operation != _cameraOperation) return;
      if (!hasPermission) {
        AppLogger.warning('Camera permissions were denied by the operator.');
        state = state.copyWith(status: CameraStatus.permissionDenied);
        return;
      }

      final cameras = await _repository.getAvailableCameras();
      if (!mounted || operation != _cameraOperation) return;
      if (cameras.isEmpty) {
        AppLogger.warning('Zero cameras detected on this device.');
        state = state.copyWith(
          status: CameraStatus.error,
          errorMessage: 'No camera devices detected on the hardware.',
        );
        return;
      }

      // Automatically default to the Rear camera (usually lensDirection == CameraLensDirection.back)
      int defaultIndex = 0;
      for (int i = 0; i < cameras.length; i++) {
        if (cameras[i].lensDirection == CameraLensDirection.back) {
          defaultIndex = i;
          break;
        }
      }

      final controller = await _repository.initializeCameraController(
        description: cameras[defaultIndex],
        // Keep the operator preview and saved layer photo at Full HD. The
        // inference encoder independently samples frames down to its bounded
        // working size, so preview quality does not dictate inference cost.
        resolutionPreset: ResolutionPreset.high,
      );

      if (!mounted || operation != _cameraOperation) {
        await _repository.disposeController(controller);
        return;
      }

      state = CameraState(
        status: CameraStatus.ready,
        controller: controller,
        availableCameras: cameras,
        selectedCameraIndex: defaultIndex,
      );
      startupWatch.stop();
      AppLogger.info(
        'Camera ready in ${startupWatch.elapsedMilliseconds}ms '
        'at ${controller.value.previewSize}',
      );
      _reconnectTimer?.cancel();
      _initializationFailures = 0;
    } catch (e, stack) {
      if (!mounted || operation != _cameraOperation) return;
      AppLogger.error('Fatal initialization error in CameraNotifier', e, stack);
      state = state.copyWith(
        status: CameraStatus.error,
        errorMessage: e.toString(),
      );
      _initializationFailures++;
      if (_initializationFailures <= 2) _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted &&
          _lifecycleState == AppLifecycleState.resumed &&
          state.status == CameraStatus.error) {
        unawaited(initialize());
      }
    });
  }

  Future<void> switchCamera() async {
    if (state.status != CameraStatus.ready ||
        state.availableCameras.length < 2) {
      AppLogger.warning(
          'Switching camera ignored: Not ready or insufficient camera hardware count.');
      return;
    }

    final currentController = state.controller;
    final nextIndex =
        (state.selectedCameraIndex + 1) % state.availableCameras.length;
    AppLogger.info(
        'Switching camera from index ${state.selectedCameraIndex} to $nextIndex');

    state = state.copyWith(status: CameraStatus.switching);

    try {
      if (currentController != null) {
        await _repository.disposeController(currentController);
      }

      final nextController = await _repository.initializeCameraController(
        description: state.availableCameras[nextIndex],
        resolutionPreset: ResolutionPreset.high,
      );

      state = state.copyWith(
        status: CameraStatus.ready,
        controller: nextController,
        selectedCameraIndex: nextIndex,
      );
    } catch (e, stack) {
      AppLogger.error('Switching camera error', e, stack);
      state = state.copyWith(
        status: CameraStatus.error,
        errorMessage: 'Failed to switch camera devices.',
      );
    }
  }

  /// Rebuilds the complete CameraX session after a surface/frame timeout.
  /// Disposal and initialization are serialized by [_pendingCameraRelease].
  Future<void> recoverCamera() async {
    if (_isRecovering || !mounted) return;
    if (_consecutiveRecoveries >= 2) {
      state = state.copyWith(
        status: CameraStatus.error,
        errorMessage:
            'Camera could not reconnect automatically. Tap Retry Camera.',
      );
      return;
    }
    _consecutiveRecoveries++;
    _isRecovering = true;
    AppLogger.warning('Camera preview stalled. Rebuilding camera session.');
    try {
      await disposeCamera();
      if (mounted && _lifecycleState == AppLifecycleState.resumed) {
        await initialize();
      }
    } finally {
      _isRecovering = false;
    }
  }

  void markPreviewHealthy() {
    _consecutiveRecoveries = 0;
  }

  Future<void> retryCamera() async {
    _consecutiveRecoveries = 0;
    _initializationFailures = 0;
    await recoverCamera();
  }

  Future<void> disposeCamera() async {
    ++_cameraOperation;
    final controller = state.controller;
    if (mounted) {
      state = const CameraState(status: CameraStatus.disposed);
    }
    if (controller == null) return;

    final release = _repository.disposeController(controller);
    _pendingCameraRelease =
        release.catchError((Object error, StackTrace stack) {
      AppLogger.error('Failed to release camera hardware', error, stack);
    });
    await _pendingCameraRelease;
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Handle application lifecycle to suspend/resume camera feed
  @override
  // The framework method uses the conventional parameter name `state`.
  // Keep the descriptive local name to avoid shadowing StateNotifier.state.
  // ignore: avoid_renaming_method_parameters
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    _lifecycleState = lifecycleState;
    if (lifecycleState == AppLifecycleState.inactive ||
        lifecycleState == AppLifecycleState.hidden ||
        lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.detached) {
      AppLogger.info(
        'App left the active foreground ($lifecycleState). '
        'Suspending camera hardware.',
      );
      unawaited(disposeCamera());
    } else if (lifecycleState == AppLifecycleState.resumed) {
      AppLogger.info('App resumed. Re-initializing camera hardware.');
      // A paused camera has already cleared its controller. Do not require an
      // existing controller here or the UI remains permanently "disconnected".
      unawaited(initialize());
    }
  }
}
