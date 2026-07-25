import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';

import '../../domain/repositories/camera_repository.dart';
import '../../data/repositories_impl/camera_repository_impl.dart';
import 'camera_state.dart';
import '../../../../utils/logger.dart';

// Provider pointing to the concrete repository implementation
final cameraRepositoryProvider = Provider<CameraRepository>((ref) {
  return CameraRepositoryImpl();
});

// StateNotifierProvider that exposes the camera controller state
final cameraNotifierProvider = StateNotifierProvider.autoDispose<CameraNotifier, CameraState>((ref) {
  final repository = ref.watch(cameraRepositoryProvider);
  final notifier = CameraNotifier(repository);
  
  // Clean up when provider is disposed
  ref.onDispose(() {
    notifier.disposeCamera();
  });
  
  return notifier;
});

class CameraNotifier extends StateNotifier<CameraState> with WidgetsBindingObserver {
  final CameraRepository _repository;

  CameraNotifier(this._repository) : super(const CameraState(status: CameraStatus.initializing)) {
    WidgetsBinding.instance.addObserver(this);
    initialize();
  }

  Future<void> initialize() async {
    state = state.copyWith(status: CameraStatus.initializing);
    try {
      final hasPermission = await _repository.requestCameraPermission();
      if (!hasPermission) {
        AppLogger.warning('Camera permissions were denied by the operator.');
        state = state.copyWith(status: CameraStatus.permissionDenied);
        return;
      }

      final cameras = await _repository.getAvailableCameras();
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
        resolutionPreset: ResolutionPreset.high,
      );

      state = CameraState(
        status: CameraStatus.ready,
        controller: controller,
        availableCameras: cameras,
        selectedCameraIndex: defaultIndex,
      );
    } catch (e, stack) {
      AppLogger.error('Fatal initialization error in CameraNotifier', e, stack);
      state = state.copyWith(
        status: CameraStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> switchCamera() async {
    if (state.status != CameraStatus.ready || state.availableCameras.length < 2) {
      AppLogger.warning('Switching camera ignored: Not ready or insufficient camera hardware count.');
      return;
    }

    final currentController = state.controller;
    final nextIndex = (state.selectedCameraIndex + 1) % state.availableCameras.length;
    AppLogger.info('Switching camera from index ${state.selectedCameraIndex} to $nextIndex');

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

  Future<void> disposeCamera() async {
    final controller = state.controller;
    if (controller != null) {
      await _repository.disposeController(controller);
    }
    state = state.copyWith(status: CameraStatus.disposed, controller: null);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Handle application lifecycle to suspend/resume camera feed
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (lifecycleState == AppLifecycleState.inactive || lifecycleState == AppLifecycleState.paused) {
      AppLogger.info('App paused. Suspending camera hardware.');
      disposeCamera();
    } else if (lifecycleState == AppLifecycleState.resumed) {
      AppLogger.info('App resumed. Re-initializing camera hardware.');
      initialize();
    }
  }
}
