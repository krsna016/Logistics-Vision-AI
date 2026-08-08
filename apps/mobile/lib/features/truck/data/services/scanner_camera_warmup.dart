import 'dart:async';

import 'package:camera/camera.dart';

import '../../../../utils/logger.dart';
import 'live_camera_text_frame.dart';

/// Owns the single camera session shared by the truck and wagon scanners.
///
/// Android camera startup is expensive and concurrent controller creation is
/// unreliable. This class serializes startup/shutdown and retains an idle
/// controller briefly so reopening a scanner is nearly instant.
class ScannerCameraWarmup {
  ScannerCameraWarmup._();

  static const _initializationTimeout = Duration(seconds: 5);
  static const _operationTimeout = Duration(seconds: 2);
  static const _retentionDuration = Duration(seconds: 15);

  static CameraController? _controller;
  static Future<CameraController>? _initializing;
  static Future<void> _disposalBarrier = Future<void>.value();
  static Timer? _releaseTimer;
  static int _activeLeases = 0;

  static Future<void> prepare() async {
    _releaseTimer?.cancel();
    await _ensureController();
  }

  static Future<CameraController?> takePrepared() async {
    _releaseTimer?.cancel();
    final controller = await _ensureController();
    _activeLeases++;
    return controller;
  }

  static Future<void> releaseController(CameraController? controller) async {
    if (controller == null) return;
    if (!identical(controller, _controller)) {
      await _disposeController(controller);
      return;
    }

    if (_activeLeases > 0) _activeLeases--;
    await _pauseController(controller);
    _scheduleRelease();
  }

  /// Releases an unused prewarmed controller after a short grace period.
  static Future<void> release() async {
    _scheduleRelease();
  }

  /// Immediately releases the camera when the app leaves the foreground.
  static Future<void> disposeNow() {
    _releaseTimer?.cancel();
    final disposal = _disposeManagedController();
    _disposalBarrier = disposal.catchError((_) {});
    return disposal;
  }

  static Future<CameraController> _ensureController() async {
    _releaseTimer?.cancel();
    await _disposalBarrier;

    final current = _controller;
    if (current?.value.isInitialized == true) return current!;

    final pending = _initializing;
    if (pending != null) return pending;

    final initialization = _createController();
    _initializing = initialization;
    try {
      final controller = await initialization;
      _controller = controller;
      return controller;
    } finally {
      if (identical(_initializing, initialization)) _initializing = null;
    }
  }

  static Future<CameraController> _createController() async {
    final stopwatch = Stopwatch()..start();
    final cameras = await cachedCameraDescriptions();
    if (cameras.isEmpty) throw StateError('No camera is available.');
    final rear = cameras.where(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );
    final description = rear.isNotEmpty ? rear.first : cameras.first;
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );
    try {
      await controller.initialize().timeout(_initializationTimeout);
      stopwatch.stop();
      if (stopwatch.elapsedMilliseconds > 800) {
        AppLogger.warning(
          'Scanner camera cold start took ${stopwatch.elapsedMilliseconds} ms.',
        );
      }
      return controller;
    } catch (error, stackTrace) {
      AppLogger.warning(
          'Scanner camera initialization failed.', error, stackTrace);
      await _disposeController(controller);
      rethrow;
    }
  }

  static void _scheduleRelease() {
    _releaseTimer?.cancel();
    _releaseTimer = Timer(_retentionDuration, () {
      if (_activeLeases == 0) unawaited(disposeNow());
    });
  }

  static Future<void> _pauseController(CameraController controller) async {
    if (controller.value.isStreamingImages) {
      try {
        await controller.stopImageStream().timeout(_operationTimeout);
      } catch (_) {
        // Disposal below remains the final recovery path.
      }
    }
    // Restore the retained camera while the closing scanner is already off
    // screen. The next truck/wagon scanner can then reveal a normal-zoom
    // preview immediately, without showing CameraX zooming back out.
    try {
      final minimum = await controller
          .getMinZoomLevel()
          .timeout(_operationTimeout);
      await controller.setZoomLevel(minimum).timeout(_operationTimeout);
    } catch (_) {
      // The scanner also verifies zoom before revealing its next preview.
    }
    try {
      await controller.setFlashMode(FlashMode.off).timeout(_operationTimeout);
    } catch (_) {
      // Some devices reject flash operations while pausing.
    }
  }

  static Future<void> _disposeManagedController() async {
    final pending = _initializing;
    if (pending != null) {
      try {
        await pending;
      } catch (_) {
        // Failed initialization has already disposed its controller.
      }
    }

    final controller = _controller;
    _controller = null;
    _activeLeases = 0;
    if (controller != null) await _disposeController(controller);
  }

  static Future<void> _disposeController(CameraController controller) async {
    await _pauseController(controller);
    try {
      await controller.dispose().timeout(_operationTimeout);
    } catch (_) {
      // The platform camera may already have been reclaimed.
    }
  }
}
