import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../utils/logger.dart';
import '../../../../services/permission_settings_service.dart';
import '../../data/services/live_camera_text_frame.dart';
import '../../data/services/scanner_camera_warmup.dart';
import '../../domain/services/vehicle_number_consensus.dart';
import '../../domain/services/vehicle_number_parser.dart';
import '../widgets/rounded_scanner_overlay.dart';
import '../widgets/scanner_capture_controls.dart';
import '../widgets/scanner_starting_view.dart';

class VehicleNumberScanScreen extends StatefulWidget {
  const VehicleNumberScanScreen({super.key});

  @override
  State<VehicleNumberScanScreen> createState() =>
      _VehicleNumberScanScreenState();
}

class _VehicleNumberScanScreenState extends State<VehicleNumberScanScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  final _consensus = VehicleNumberConsensus();
  String? _error;
  bool _initializing = true;
  bool _torchOn = false;
  bool _processingFrame = false;
  bool _recognizerBusy = false;
  Future<RecognizedText>? _activeRecognition;
  bool _liveScanning = false;
  bool _resultDelivered = false;
  Future<void>? _activeFrameProcessing;
  Timer? _candidateExpiryTimer;
  Timer? _cameraWatchdogTimer;
  DateTime _lastFrameStarted = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime? _lastCameraFrameAt;
  String? _liveCandidate;
  bool _lifecyclePaused = false;
  int _framesWithoutCandidate = 0;
  final Stopwatch _sessionStopwatch = Stopwatch()..start();
  double _currentZoom = 1;
  double _baseZoom = 1;
  double _minimumZoom = 1;
  double _maximumZoom = 1;
  bool _cameraRecoveryInProgress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Keep native camera startup away from the route's opening animation. In
    // the usual path the controller is already prewarmed, so this only yields
    // long enough for the first scanner frame to paint.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 220), () {
        if (mounted) unawaited(_initialize());
      });
    });
  }

  Future<void> _initialize() async {
    final cameraPermission = await Permission.camera.status;
    if (!cameraPermission.isGranted) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _error =
              'Camera permission is required. Enable Camera in Settings, then return here.';
        });
      }
      return;
    }
    try {
      final controller = await ScannerCameraWarmup.takePrepared();
      if (controller == null) throw StateError('No camera is available.');
      if (!mounted) {
        await ScannerCameraWarmup.releaseController(controller);
        return;
      }
      // Keep the prepared camera hidden until its hardware zoom is back at
      // the default. A retained CameraX controller otherwise briefly paints
      // the zoom level from the previous scanner session.
      _controller = controller;
      await _initializeZoom(controller);
      if (!mounted || _controller != controller) {
        await ScannerCameraWarmup.releaseController(controller);
        return;
      }
      setState(() {
        _initializing = false;
      });
      // Paint the camera preview first, then attach the analysis stream. This
      // prevents route animation, texture creation and OCR startup competing in
      // the same frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future<void>.delayed(const Duration(milliseconds: 120), () {
          if (mounted && _controller == controller && !_lifecyclePaused) {
            unawaited(_startLiveScanning(controller));
          }
        });
      });
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _initializing = false;
          _error = 'Camera took too long to start. Tap retry to open it again.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _error =
              'Camera permission is required. Enable Camera in Settings, then return here.';
        });
      }
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

  Future<void> _initializeZoom(CameraController controller) async {
    try {
      final minimum = await controller.getMinZoomLevel();
      final maximum = await controller.getMaxZoomLevel();
      if (!mounted || _controller != controller) return;
      _minimumZoom = minimum;
      _maximumZoom = maximum;
      _currentZoom = minimum;
      _baseZoom = minimum;
      await controller.setZoomLevel(minimum);
    } catch (_) {
      // Keep the camera's default zoom when the device does not expose zoom.
    }
  }

  Future<void> _setPinchZoom(double scale) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final zoom =
        (_baseZoom * scale).clamp(_minimumZoom, _maximumZoom).toDouble();
    if ((zoom - _currentZoom).abs() < 0.01) return;
    _currentZoom = zoom;
    try {
      await controller.setZoomLevel(zoom);
    } catch (_) {
      // Ignore a zoom update if CameraX is switching or closing.
    }
  }

  Future<void> _startLiveScanning(CameraController controller) async {
    if (_liveScanning ||
        _lifecyclePaused ||
        !controller.value.isInitialized ||
        controller.value.isStreamingImages) {
      return;
    }
    try {
      _consensus.reset();
      _lastCameraFrameAt = DateTime.now();
      await controller.startImageStream((image) {
        final now = DateTime.now();
        _lastCameraFrameAt = now;
        if (_resultDelivered ||
            _processingFrame ||
            _recognizerBusy ||
            now.difference(_lastFrameStarted) <
                const Duration(milliseconds: 240)) {
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
      _startCameraWatchdog(controller);
      if (mounted) setState(() {});
    } catch (_) {
      _liveScanning = false;
      // Manual capture remains available on devices without image streaming.
    }
  }

  void _startCameraWatchdog(CameraController controller) {
    _cameraWatchdogTimer?.cancel();
    _cameraWatchdogTimer = Timer.periodic(
      const Duration(milliseconds: 750),
      (_) {
        if (!mounted ||
            _lifecyclePaused ||
            _resultDelivered ||
            _cameraRecoveryInProgress ||
            _controller != controller) {
          return;
        }
        final lastFrameAt = _lastCameraFrameAt;
        final streamStalled = lastFrameAt != null &&
            DateTime.now().difference(lastFrameAt) >
                const Duration(milliseconds: 1800);
        if (controller.value.hasError ||
            controller.value.isPreviewPaused ||
            streamStalled) {
          unawaited(_recoverCameraSession());
        }
      },
    );
  }

  Future<void> _recoverCameraSession() async {
    if (_cameraRecoveryInProgress ||
        _lifecyclePaused ||
        _resultDelivered ||
        !mounted) {
      return;
    }
    _cameraRecoveryInProgress = true;
    _cameraWatchdogTimer?.cancel();
    _candidateExpiryTimer?.cancel();
    _liveScanning = false;
    _processingFrame = false;
    _controller = null;
    setState(() {
      _initializing = true;
      _error = null;
      _liveCandidate = null;
      _torchOn = false;
    });
    AppLogger.warning('Truck scanner camera stalled. Rebuilding session.');
    await ScannerCameraWarmup.disposeNow();
    if (mounted && !_lifecyclePaused && !_resultDelivered) {
      await _initialize();
    }
    _cameraRecoveryInProgress = false;
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
      _cameraWatchdogTimer?.cancel();
    }
    if (waitForActiveFrame) await _activeFrameProcessing;
  }

  Future<void> _processLiveFrame(
    CameraController controller,
    CameraImage cameraImage,
  ) async {
    final frameStopwatch = Stopwatch()..start();
    final useExpandedRegion = _framesWithoutCandidate >= 3;
    final roiWidth = useExpandedRegion ? 0.96 : 0.84;
    final roiHeight = useExpandedRegion ? 0.52 : 0.34;
    try {
      if (!cameraFrameHasSufficientQuality(
        cameraImage,
        controller.description.sensorOrientation,
        roiWidthFraction: roiWidth,
        roiHeightFraction: roiHeight,
      )) {
        return;
      }
      final inputImage = inputImageFromCameraFrame(
        cameraImage,
        controller.description.sensorOrientation,
        roiWidthFraction: roiWidth,
        roiHeightFraction: roiHeight,
      );
      if (inputImage == null) return;

      final recognition = _recognizer.processImage(inputImage);
      _activeRecognition = recognition;
      _recognizerBusy = true;
      unawaited(
        recognition.then<void>((_) {}, onError: (_, __) {}).whenComplete(() {
          if (identical(_activeRecognition, recognition)) {
            _recognizerBusy = false;
            _activeRecognition = null;
          }
        }),
      );
      final result =
          await recognition.timeout(const Duration(milliseconds: 1200));
      if (_lifecyclePaused || !mounted) return;
      final candidates = VehicleNumberParser.candidatesFromText(result.text)
          .where(VehicleNumberParser.looksLikeIndianVehicleNumber)
          .toList();
      if (candidates.isEmpty) {
        _framesWithoutCandidate =
            (_framesWithoutCandidate + 1).clamp(0, 8).toInt();
      } else {
        _framesWithoutCandidate = 0;
      }
      final accepted = _consensus.addCandidates(candidates);
      final leading = _consensus.leadingCandidate;
      if (candidates.isNotEmpty && leading != null) {
        _showLiveCandidate(leading);
      }
      if (accepted != null && mounted && !_resultDelivered) {
        _resultDelivered = true;
        _liveScanning = false;
        _candidateExpiryTimer?.cancel();
        AppLogger.debug(
          'Truck scanner confirmed in ${_sessionStopwatch.elapsedMilliseconds} ms.',
        );
        // Pop immediately. Stream shutdown is intentionally handled after the
        // closing animation in dispose so Camera2 cannot stall that animation.
        Navigator.of(context).pop(accepted);
      }
    } on TimeoutException {
      _replaceStalledRecognizer();
      _framesWithoutCandidate =
          (_framesWithoutCandidate + 1).clamp(0, 8).toInt();
      _candidateExpiryTimer?.cancel();
      _consensus.reset();
      if (mounted) setState(() => _liveCandidate = null);
    } catch (_) {
      // A bad preview frame is expected occasionally; the next frame retries.
    } finally {
      frameStopwatch.stop();
      if (frameStopwatch.elapsedMilliseconds > 500) {
        AppLogger.warning(
          'Truck OCR frame took ${frameStopwatch.elapsedMilliseconds} ms.',
        );
      }
      _processingFrame = false;
    }
  }

  void _replaceStalledRecognizer() {
    final stalledRecognizer = _recognizer;
    _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    _activeRecognition = null;
    _recognizerBusy = false;
    unawaited(
      stalledRecognizer.close().timeout(const Duration(seconds: 1)).catchError(
            (_) {},
          ),
    );
  }

  void _showLiveCandidate(String candidate) {
    _candidateExpiryTimer?.cancel();
    if (mounted && candidate != _liveCandidate) {
      setState(() {
        _liveCandidate = candidate;
        _error = null;
      });
    }
    _candidateExpiryTimer = Timer(const Duration(milliseconds: 1500), () {
      _consensus.reset();
      if (mounted) setState(() => _liveCandidate = null);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_resumeAfterLifecyclePause());
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_pauseForLifecycle());
    }
  }

  Future<void> _pauseForLifecycle() async {
    if (_lifecyclePaused) return;
    _lifecyclePaused = true;
    _cameraWatchdogTimer?.cancel();
    _candidateExpiryTimer?.cancel();
    _cameraWatchdogTimer?.cancel();
    final controller = _controller;
    await _stopLiveScanning(controller, waitForActiveFrame: false);
    await ScannerCameraWarmup.disposeNow();
    if (mounted) {
      setState(() {
        _controller = null;
        _liveCandidate = null;
        _torchOn = false;
      });
    }
  }

  Future<void> _resumeAfterLifecyclePause() async {
    if (!_lifecyclePaused || !mounted) return;
    _lifecyclePaused = false;
    _framesWithoutCandidate = 0;
    _resultDelivered = false;
    _sessionStopwatch
      ..reset()
      ..start();
    setState(() {
      _initializing = true;
      _error = null;
    });
    await _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _candidateExpiryTimer?.cancel();
    final controller = _controller;
    _controller = null;
    unawaited(_disposeScannerResources(controller));
    super.dispose();
  }

  Future<void> _disposeScannerResources(CameraController? controller) async {
    // Camera2 stopImageStream can block the Android main thread for hundreds of
    // milliseconds. Let the route transition finish before touching it.
    await Future<void>.delayed(const Duration(milliseconds: 320));
    await _stopLiveScanning(controller);
    try {
      await _activeRecognition?.timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      // Closing the recognizer below is the final recovery path.
    }
    try {
      await _recognizer.close().timeout(const Duration(seconds: 1));
    } catch (_) {
      // Native recognition may already have been reclaimed.
    }
    await ScannerCameraWarmup.releaseController(controller);
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
        duration: const Duration(milliseconds: 280),
        reverseDuration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _initializing
            ? const ScannerStartingView()
            : _error != null && controller == null
                ? KeyedSubtree(
                    key: const ValueKey('camera-error'),
                    child: _ErrorState(
                      message: _error!,
                    ),
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
                                onScaleStart: (_) => _baseZoom = _currentZoom,
                                onScaleUpdate: (details) {
                                  if (details.pointerCount == 2 &&
                                      details.scale != 1) {
                                    unawaited(_setPinchZoom(details.scale));
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
                              onToggleTorch:
                                  controller == null ? null : _toggleTorch,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => PermissionSettingsService.openAppPermissions(),
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Open camera settings'),
              ),
            ],
          ),
        ),
      );
}
