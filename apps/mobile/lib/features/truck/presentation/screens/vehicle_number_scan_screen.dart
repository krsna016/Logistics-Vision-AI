import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/services/live_camera_text_frame.dart';
import '../../data/services/scanner_camera_warmup.dart';
import '../../data/services/vehicle_plate_image_preprocessor.dart';
import '../../domain/services/vehicle_number_consensus.dart';
import '../../domain/services/vehicle_number_parser.dart';
import '../widgets/rounded_scanner_overlay.dart';
import '../widgets/scanner_capture_controls.dart';

class VehicleNumberScanScreen extends StatefulWidget {
  const VehicleNumberScanScreen({super.key});

  @override
  State<VehicleNumberScanScreen> createState() =>
      _VehicleNumberScanScreenState();
}

class _VehicleNumberScanScreenState extends State<VehicleNumberScanScreen> {
  CameraController? _controller;
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _picker = ImagePicker();
  final _consensus = VehicleNumberConsensus();
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  String? _error;
  bool _initializing = true;
  bool _scanning = false;
  bool _torchOn = false;
  bool _processingFrame = false;
  bool _liveScanning = false;
  Future<void>? _activeFrameProcessing;
  DateTime _lastFrameStarted = DateTime.fromMillisecondsSinceEpoch(0);
  String? _liveCandidate;
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
      unawaited(_loadCameraList(controller));
      unawaited(_loadZoomLevels(controller));
      unawaited(_startLiveScanning(controller));
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

  Future<void> _loadCameraList(CameraController controller) async {
    try {
      final cameras = await cachedCameraDescriptions();
      final index = cameras.indexWhere(
        (camera) => camera.name == controller.description.name,
      );
      if (!mounted || _controller != controller) return;
      setState(() {
        _cameras = cameras;
        _cameraIndex = index < 0 ? 0 : index;
      });
    } catch (_) {
      // Flip remains unavailable if the device camera list cannot be read.
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
      ResolutionPreset.high,
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

  Future<void> _switchCamera() async {
    if (_scanning || _initializing) return;
    final current = _controller;
    if (current == null || _cameras.length < 2) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No other camera is available.')),
        );
      }
      return;
    }

    setState(() {
      _initializing = true;
      _torchOn = false;
      _error = null;
    });
    try {
      await _stopLiveScanning(current);
      if (!mounted) return;
      await current.dispose();
      final nextIndex = (_cameraIndex + 1) % _cameras.length;
      final next = CameraController(
        _cameras[nextIndex],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      await next.initialize();
      if (!mounted) {
        await next.dispose();
        return;
      }
      setState(() {
        _controller = next;
        _cameraIndex = nextIndex;
        _initializing = false;
        _zoom = 1;
        _gestureStartZoom = 1;
      });
      unawaited(_loadZoomLevels(next));
      unawaited(_startLiveScanning(next));
    } catch (_) {
      if (mounted) {
        setState(() {
          _controller = null;
          _initializing = false;
          _error = 'Could not switch the camera. Please try again.';
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_scanning) return;
    try {
      if (_torchOn) await _toggleTorch();
      await _stopLiveScanning(_controller);
      if (!mounted) return;
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null || !mounted) {
        if (mounted && _controller != null) {
          unawaited(_startLiveScanning(_controller!));
        }
        return;
      }
      setState(() {
        _scanning = true;
        _error = null;
      });
      await _readImage(image.path);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not open this gallery image.');
        if (_controller != null) unawaited(_startLiveScanning(_controller!));
      }
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
      await _stopLiveScanning(controller);
      if (!mounted) return;
      final image = await controller.takePicture();
      await _readImage(image.path);
    } catch (_) {
      if (mounted) {
        setState(() {
          _scanning = false;
          _error = 'Could not read this image. Please try again.';
        });
        unawaited(_startLiveScanning(controller));
      }
    } finally {
      if (mounted && _scanning) setState(() => _scanning = false);
    }
  }

  Future<void> _readImage(String imagePath) async {
    try {
      final focusedImage =
          await VehiclePlateImagePreprocessor.createFocusedImage(imagePath);
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
        if (_controller != null) unawaited(_startLiveScanning(_controller!));
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
        if (_controller != null) unawaited(_startLiveScanning(_controller!));
      }
    } finally {
      if (mounted && _scanning) setState(() => _scanning = false);
    }
  }

  Future<void> _startLiveScanning(CameraController controller) async {
    if (_liveScanning ||
        _scanning ||
        !controller.value.isInitialized ||
        controller.value.isStreamingImages) {
      return;
    }
    try {
      _consensus.reset();
      await controller.startImageStream((image) {
        final now = DateTime.now();
        if (_processingFrame ||
            _scanning ||
            now.difference(_lastFrameStarted) <
                const Duration(milliseconds: 140)) {
          return;
        }
        _lastFrameStarted = now;
        _processingFrame = true;
        final processing = _processLiveFrame(controller, image);
        _activeFrameProcessing = processing;
        unawaited(processing.whenComplete(() {
          if (identical(_activeFrameProcessing, processing)) {
            _activeFrameProcessing = null;
          }
        }));
      });
      _liveScanning = true;
      if (mounted) setState(() {});
    } catch (_) {
      _liveScanning = false;
      // Manual capture remains available on devices without image streaming.
    }
  }

  Future<void> _stopLiveScanning(
    CameraController? controller, {
    bool waitForActiveFrame = true,
  }) async {
    if (controller == null || !controller.value.isStreamingImages) {
      _liveScanning = false;
      if (waitForActiveFrame) await _activeFrameProcessing;
      return;
    }
    try {
      await controller.stopImageStream();
    } catch (_) {
      // The controller may already be stopping or disposing.
    } finally {
      _liveScanning = false;
    }
    if (waitForActiveFrame) await _activeFrameProcessing;
  }

  Future<void> _processLiveFrame(
    CameraController controller,
    CameraImage cameraImage,
  ) async {
    try {
      final inputImage = inputImageFromCameraFrame(
        cameraImage,
        controller.description.sensorOrientation,
        roiWidthFraction: 0.84,
        roiHeightFraction: 0.34,
      );
      if (inputImage == null) return;

      final result = await _recognizer.processImage(inputImage);
      if (_scanning || !mounted) return;
      final candidates = VehicleNumberParser.candidatesFromText(result.text)
          .where(VehicleNumberParser.looksLikeIndianVehicleNumber)
          .toList();
      final accepted = _consensus.addCandidates(candidates);
      final leading = _consensus.leadingCandidate;
      if (mounted && leading != _liveCandidate) {
        setState(() {
          _liveCandidate = leading;
          _error = null;
        });
      }
      if (accepted != null && mounted) {
        await _stopLiveScanning(controller, waitForActiveFrame: false);
        if (mounted) Navigator.of(context).pop(accepted);
      }
    } catch (_) {
      // A bad preview frame is expected occasionally; the next frame retries.
    } finally {
      _processingFrame = false;
    }
  }

  @override
  void dispose() {
    final controller = _controller;
    _controller = null;
    unawaited(_disposeScannerResources(controller));
    super.dispose();
  }

  Future<void> _disposeScannerResources(CameraController? controller) async {
    await _stopLiveScanning(controller);
    await _recognizer.close();
    await controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan vehicle number'),
        backgroundColor: Colors.black,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 150),
        child: _initializing
            ? const Center(
                key: ValueKey('camera-loading'),
                child: CircularProgressIndicator(),
              )
            : _error != null && controller == null
                ? KeyedSubtree(
                    key: const ValueKey('camera-error'),
                    child: _ErrorState(message: _error!),
                  )
                : Stack(
                    key: const ValueKey('camera-ready'),
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
                                      _setZoom(
                                          _gestureStartZoom * details.scale),
                                    );
                                  }
                                },
                                child: CameraPreview(controller),
                              ),
                            ),
                          ),
                        ),
                      const Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(28)),
                            child: RoundedScannerOverlay(
                              widthFactor: 0.84,
                              aspectRatio: 1.65,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: MediaQuery.of(context).padding.bottom + 20,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _liveCandidate == null
                                    ? 'Place the full plate inside the frame'
                                    : 'Reading $_liveCandidate… hold steady',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (_error != null)
                              Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child:
                                    Text(_error!, textAlign: TextAlign.center),
                              ),
                            ScannerCaptureControls(
                              torchOn: _torchOn,
                              isScanning: _scanning,
                              onToggleTorch:
                                  controller == null ? null : _toggleTorch,
                              onCapture: _captureAndRead,
                              onGallery: _pickFromGallery,
                              onFlipCamera: _switchCamera,
                              captureLabel: 'Capture plate',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
