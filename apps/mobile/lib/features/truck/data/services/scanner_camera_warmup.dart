import 'package:camera/camera.dart';

import 'live_camera_text_frame.dart';

class ScannerCameraWarmup {
  ScannerCameraWarmup._();

  static CameraController? _warmedController;
  static Future<void>? _pending;

  static Future<void> prepare() {
    if (_warmedController?.value.isInitialized == true) {
      return Future<void>.value();
    }
    return _pending ??= _prepareInternal();
  }

  static Future<void> _prepareInternal() async {
    try {
      final cameras = await cachedCameraDescriptions();
      if (cameras.isEmpty) return;
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
      await controller.initialize();
      _warmedController = controller;
    } catch (_) {
      // The scanner will retry camera initialization when opened.
    } finally {
      _pending = null;
    }
  }

  static Future<CameraController?> takePrepared() async {
    await prepare();
    final controller = _warmedController;
    _warmedController = null;
    return controller?.value.isInitialized == true ? controller : null;
  }

  static Future<void> release() async {
    final controller = _warmedController;
    _warmedController = null;
    await controller?.dispose();
  }
}
