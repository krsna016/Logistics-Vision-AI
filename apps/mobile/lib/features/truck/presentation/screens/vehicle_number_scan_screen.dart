import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../../theme/app_theme.dart';
import '../../data/services/live_camera_text_frame.dart';
import '../../data/services/scanner_camera_warmup.dart';
import '../../data/services/vehicle_plate_image_preprocessor.dart';
import '../../domain/services/vehicle_number_parser.dart';

class VehicleNumberScanScreen extends StatefulWidget {
  const VehicleNumberScanScreen({super.key});

  @override
  State<VehicleNumberScanScreen> createState() =>
      _VehicleNumberScanScreenState();
}

class _VehicleNumberScanScreenState extends State<VehicleNumberScanScreen> {
  CameraController? _controller;
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  String? _error;
  bool _initializing = true;
  bool _scanning = false;
  bool _torchOn = false;
  double _zoom = 1;
  double _minZoom = 1;
  double _maxZoom = 1;
  double _gestureStartZoom = 1;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final controller = await ScannerCameraWarmup.takePrepared() ??
          await _createCameraController();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _initializing = false;
        _zoom = _minZoom;
        _gestureStartZoom = _minZoom;
      });
      unawaited(_loadZoomLevels(controller));
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _scanning = false;
          _error =
              'Reading took too long. Move closer to the plate and capture again.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _error =
              'Camera could not be started. You can enter the number manually.';
        });
      }
    }
  }

  Future<CameraController> _createCameraController() async {
    final cameras = await cachedCameraDescriptions();
    final rear = cameras.where(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );
    final description = rear.isNotEmpty ? rear.first : cameras.first;
    final controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );
    await controller.initialize();
    return controller;
  }

  Future<void> _loadZoomLevels(CameraController controller) async {
    try {
      final minZoom = await controller.getMinZoomLevel();
      final maxZoom = await controller.getMaxZoomLevel();
      if (!mounted || _controller != controller) return;
      setState(() {
        _minZoom = minZoom;
        _maxZoom = maxZoom;
        _zoom = minZoom;
        _gestureStartZoom = minZoom;
      });
    } catch (_) {
      // Keep safe defaults when zoom is unsupported.
    }
  }

  Future<void> _toggleTorch() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      final next = !_torchOn;
      await controller.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _torchOn = next);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flashlight is not available.')),
        );
      }
    }
  }

  Future<void> _setZoom(double zoom) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final nextZoom = zoom.clamp(_minZoom, _maxZoom).toDouble();
    if ((nextZoom - _zoom).abs() < 0.01) return;
    _zoom = nextZoom;
    try {
      await controller.setZoomLevel(nextZoom);
    } catch (_) {
      // Some devices expose zoom values but reject a gesture during capture.
    }
  }

  Future<void> _captureAndRead() async {
    final controller = _controller;
    if (_scanning || controller == null || !controller.value.isInitialized) {
      return;
    }

    setState(() {
      _scanning = true;
      _error = null;
    });

    try {
      final image = await controller.takePicture();

      final focusedImage =
          await VehiclePlateImagePreprocessor.createFocusedImage(image.path);
      final result = await _recognizer
          .processImage(InputImage.fromFilePath(focusedImage))
          .timeout(const Duration(seconds: 5));
      final candidates = VehicleNumberParser.candidatesFromText(result.text)
          .where(VehicleNumberParser.looksLikeIndianVehicleNumber)
          .toList();
      if (!mounted) return;
      if (candidates.isEmpty) {
        setState(() {
          _scanning = false;
          _error =
              'No readable vehicle number found. Move closer and try again.';
        });
        return;
      }
      setState(() => _scanning = false);
      Navigator.of(context).pop(candidates.first);
    } catch (_) {
      if (mounted) {
        setState(() {
          _scanning = false;
          _error = 'Could not read this image. Please try again.';
        });
      }
    } finally {
      if (mounted && _scanning) setState(() => _scanning = false);
    }
  }

  @override
  void dispose() {
    _recognizer.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan vehicle number'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: controller == null ? null : _toggleTorch,
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
            tooltip: 'Toggle flashlight',
          ),
        ],
      ),
      body: _initializing
          ? const Center(child: CircularProgressIndicator())
          : _error != null && controller == null
              ? _ErrorState(message: _error!)
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    if (controller != null && controller.value.isInitialized)
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onScaleStart: (_) {
                                _gestureStartZoom = _zoom;
                              },
                              onScaleUpdate: (details) {
                                if (details.scale != 1) {
                                  unawaited(
                                    _setZoom(_gestureStartZoom * details.scale),
                                  );
                                }
                              },
                              child: CameraPreview(controller),
                            ),
                          ),
                        ),
                      ),
                    Center(
                      child: IgnorePointer(
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.68,
                          height: 165,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.warningColor,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 16,
                      child: Column(
                        children: [
                          if (_error != null)
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(_error!, textAlign: TextAlign.center),
                            ),
                          Center(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.62),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _scanning ? null : _captureAndRead,
                                icon: _scanning
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Icon(Icons.camera_alt_outlined,
                                        size: 18),
                                label: Text(
                                    _scanning ? 'Reading' : 'Capture plate'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      AppTheme.primaryColor,
                                  disabledForegroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      );
}
