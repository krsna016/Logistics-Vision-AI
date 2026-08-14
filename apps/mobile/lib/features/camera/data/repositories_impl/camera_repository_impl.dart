import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/errors/failures.dart';
import '../../../../utils/logger.dart';
import '../../domain/repositories/camera_repository.dart';

class CameraRepositoryImpl implements CameraRepository {
  @override
  Future<bool> requestCameraPermission() async {
    try {
      AppLogger.info('Checking camera permissions...');
      // Ask on every camera-session start. Android returns the already-granted
      // status immediately, while a denied permission gets another prompt on
      // the next attempt instead of being silently short-circuited.
      final requestStatus = await Permission.camera.request();
      AppLogger.info('Camera permission request status: $requestStatus');
      return requestStatus.isGranted;
    } catch (e, stack) {
      AppLogger.error('Exception during permission request', e, stack);
      throw const DatabaseException('Failed to request camera permissions');
    }
  }

  @override
  Future<List<CameraDescription>> getAvailableCameras() async {
    try {
      AppLogger.info('Querying available system cameras...');
      final cameras = await availableCameras();
      AppLogger.info('Found ${cameras.length} optical cameras.');
      return cameras;
    } on CameraException catch (e, stack) {
      AppLogger.error(
          'Camera Exception while listing devices', e.description, stack);
      throw DatabaseException('Listing cameras failed: ${e.description}');
    } catch (e, stack) {
      AppLogger.error('Unexpected error listing cameras', e, stack);
      throw const DatabaseException('Failed to locate cameras');
    }
  }

  @override
  Future<CameraController> initializeCameraController({
    required CameraDescription description,
    required ResolutionPreset resolutionPreset,
  }) async {
    CameraController? controller;
    try {
      AppLogger.info(
          'Constructing camera controller for camera: ${description.name}');
      controller = CameraController(
        description,
        resolutionPreset,
        enableAudio: false, // Audio disabled for carton counting requirements
        imageFormatGroup:
            ImageFormatGroup.yuv420, // Prep for future ONNX NPU conversion
      );

      AppLogger.info('Initializing camera controller...');
      await controller.initialize().timeout(const Duration(seconds: 5));
      AppLogger.info('Camera initialization completed successfully.');
      return controller;
    } on CameraException catch (e, stack) {
      if (controller != null) await disposeController(controller);
      AppLogger.error(
          'Camera Exception during initialization', e.description, stack);
      throw DatabaseException('Camera setup error: ${e.description}');
    } catch (e, stack) {
      if (controller != null) await disposeController(controller);
      AppLogger.error(
          'Unexpected error during camera initialization', e, stack);
      throw const DatabaseException('Failed to initialize camera controller');
    }
  }

  @override
  Future<void> disposeController(CameraController controller) async {
    try {
      AppLogger.info('Disposing camera controller...');
      await controller.dispose().timeout(const Duration(seconds: 3));
      AppLogger.info('Camera controller disposed.');
    } catch (e, stack) {
      AppLogger.error('Error disposing camera controller', e, stack);
    }
  }
}
