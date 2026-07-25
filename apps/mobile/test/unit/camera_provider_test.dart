import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/features/camera/domain/repositories/camera_repository.dart';
import 'package:mobile/features/camera/presentation/providers/camera_notifier.dart';
import 'package:mobile/features/camera/presentation/providers/camera_state.dart';

// A mock camera repository for validation testing
class MockCameraRepository implements CameraRepository {
  bool shouldGrantPermission = true;
  bool shouldThrowError = false;
  List<CameraDescription> mockCameras = [
    const CameraDescription(
      name: 'back_camera',
      lensDirection: CameraLensDirection.back,
      sensorOrientation: 90,
    ),
    const CameraDescription(
      name: 'front_camera',
      lensDirection: CameraLensDirection.front,
      sensorOrientation: 270,
    ),
  ];

  @override
  Future<bool> requestCameraPermission() async {
    if (shouldThrowError) throw Exception('Simulated permission exception');
    return shouldGrantPermission;
  }

  @override
  Future<List<CameraDescription>> getAvailableCameras() async {
    if (shouldThrowError) throw Exception('Simulated list exception');
    return mockCameras;
  }

  @override
  Future<CameraController> initializeCameraController({
    required CameraDescription description,
    required ResolutionPreset resolutionPreset,
  }) async {
    if (shouldThrowError) throw Exception('Simulated initialization exception');
    // Note: We cannot easily instantiate a real CameraController in a pure Dart test
    // without full Flutter bindings, but we can verify code paths and state changes.
    throw UnimplementedError('Simulated controller initialization');
  }

  @override
  Future<void> disposeController(CameraController controller) async {}
}

void main() {
  late MockCameraRepository mockRepo;

  setUp(() {
    mockRepo = MockCameraRepository();
  });

  ProviderContainer makeContainer(MockCameraRepository repo) {
    final container = ProviderContainer(
      overrides: [
        cameraRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('CameraNotifier Provider Transitions', () {
    test('Verify initial status is Initializing', () {
      final container = makeContainer(mockRepo);
      // Notifier starts initialization in constructor. We check the initial state.
      final state = container.read(cameraNotifierProvider);
      expect(state.status, equals(CameraStatus.initializing));
    });

    test('Verify PermissionDenied status when permission request fails', () async {
      mockRepo.shouldGrantPermission = false;
      final container = makeContainer(mockRepo);

      // Wait for notifier initialization process to complete
      await container.read(cameraNotifierProvider.notifier).initialize();

      final state = container.read(cameraNotifierProvider);
      expect(state.status, equals(CameraStatus.permissionDenied));
    });

    test('Verify Error status on hardware listings failure', () async {
      mockRepo.shouldThrowError = true;
      final container = makeContainer(mockRepo);

      await container.read(cameraNotifierProvider.notifier).initialize();

      final state = container.read(cameraNotifierProvider);
      expect(state.status, equals(CameraStatus.error));
      expect(state.errorMessage, contains('Simulated permission exception'));
    });
  });
}
