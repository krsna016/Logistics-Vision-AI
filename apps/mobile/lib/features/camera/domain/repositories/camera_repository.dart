import 'package:camera/camera.dart';

abstract class CameraRepository {
  /// Check and request device camera permissions.
  Future<bool> requestCameraPermission();

  /// Retrieve all available optical camera devices.
  Future<List<CameraDescription>> getAvailableCameras();

  /// Initialize a camera controller instance.
  Future<CameraController> initializeCameraController({
    required CameraDescription description,
    required ResolutionPreset resolutionPreset,
  });

  /// Safely dispose of the camera controller instance.
  Future<void> disposeController(CameraController controller);
}
