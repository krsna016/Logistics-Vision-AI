import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

enum CameraStatus {
  initializing,
  ready,
  permissionDenied,
  error,
  switching,
  disposed,
}

@immutable
class CameraState {
  final CameraStatus status;
  final CameraController? controller;
  final String? errorMessage;
  final List<CameraDescription> availableCameras;
  final int selectedCameraIndex;
  final bool isUltraWide;

  const CameraState({
    required this.status,
    this.controller,
    this.errorMessage,
    this.availableCameras = const [],
    this.selectedCameraIndex = 0,
    this.isUltraWide = false,
  });

  CameraState copyWith({
    CameraStatus? status,
    CameraController? controller,
    String? errorMessage,
    List<CameraDescription>? availableCameras,
    int? selectedCameraIndex,
    bool? isUltraWide,
  }) {
    return CameraState(
      status: status ?? this.status,
      controller: controller ?? this.controller,
      errorMessage: errorMessage ?? this.errorMessage,
      availableCameras: availableCameras ?? this.availableCameras,
      selectedCameraIndex: selectedCameraIndex ?? this.selectedCameraIndex,
      isUltraWide: isUltraWide ?? this.isUltraWide,
    );
  }
}
