import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../../utils/logger.dart';
import '../../../truck/data/services/live_camera_text_frame.dart';
import '../../../truck/data/services/scanner_camera_warmup.dart';
import '../../domain/services/wagon_number_consensus.dart';
import '../../domain/services/wagon_number_parser.dart';
import '../../../truck/presentation/widgets/rounded_scanner_overlay.dart';
import '../../../truck/presentation/widgets/scanner_capture_controls.dart';
import '../../../truck/presentation/widgets/scanner_starting_view.dart';

class WagonNumberScanScreen extends StatefulWidget {
  const WagonNumberScanScreen({super.key});

  @override
  State<WagonNumberScanScreen> createState() => _WagonNumberScanScreenState();
}

class _WagonNumberScanScreenState extends State<WagonNumberScanScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _consensus = WagonNumberConsensus();
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
  DateTime _lastFrameStarted = DateTime.fromMillisecondsSinceEpoch(0);
  String? _liveCandidate;
  bool _lifecyclePaused = false;
  final Stopwatch _sessionStopwatch = Stopwatch()..start();
  double _zoom = 1;
  double _minZoom = 1;
  double _maxZoom = 1;
  double _gestureStartZoom = 1;

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
    try {
      final controller = await ScannerCameraWarmup.takePrepared();
      if (controller == null) throw StateError('No camera is available.');
      if (!mounted) {
        await ScannerCameraWarmup.releaseController(controller);
        return;
      }
      setState(() {
        _controller = controller;
        _initializing = false;
        _zoom = _minZoom;
        _gestureStartZoom = _minZoom;
      });
      unawaited(_loadZoomLevels(controller));
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
    } catch (_) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _error =
              'Camera could not be started. You can enter the wagon number manually.';
        });
      }
    }
  }

  Future<void> _retryInitialize() async {
    if (_initializing) return;
    setState(() {
      _initializing = true;
      _error = null;
    });
    await _initialize();
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
    } catch (_) {}
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
      await controller.startImageStream((image) {
        final now = DateTime.now();
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
      if (mounted) setState(() {});
    } catch (_) {
      _liveScanning = false;
      // Gallery remains available on devices without image streaming.
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
    final frameStopwatch = Stopwatch()..start();
    try {
      if (!cameraFrameHasSufficientQuality(
        cameraImage,
        controller.description.sensorOrientation,
        roiWidthFraction: 0.84,
        roiHeightFraction: 0.58,
      )) {
        return;
      }
      final inputImage = inputImageFromCameraFrame(
        cameraImage,
        controller.description.sensorOrientation,
        roiWidthFraction: 0.84,
        roiHeightFraction: 0.58,
      );
      if (inputImage == null) return;

      final recognition = _recognizer.processImage(inputImage);
      _activeRecognition = recognition;
      _recognizerBusy = true;
      unawaited(
        recognition.then<void>((_) {}, onError: (_, __) {}).whenComplete(() {
          _recognizerBusy = false;
          if (identical(_activeRecognition, recognition)) {
            _activeRecognition = null;
          }
        }),
      );
      final result =
          await recognition.timeout(const Duration(milliseconds: 1200));
      if (_lifecyclePaused || !mounted) return;
      final candidates = WagonNumberParser.candidatesFromText(result.text)
          .where(WagonNumberParser.looksLikeWagonNumber)
          .toList();
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
          'Wagon scanner confirmed in ${_sessionStopwatch.elapsedMilliseconds} ms.',
        );
        // Pop immediately. Stream shutdown is intentionally handled after the
        // closing animation in dispose so Camera2 cannot stall that animation.
        Navigator.of(context).pop(accepted);
      }
    } on TimeoutException {
      _candidateExpiryTimer?.cancel();
      _consensus.reset();
      if (mounted) setState(() => _liveCandidate = null);
    } catch (_) {
      // A bad preview frame is expected occasionally; the next frame retries.
    } finally {
      frameStopwatch.stop();
      if (frameStopwatch.elapsedMilliseconds > 500) {
        AppLogger.warning(
          'Wagon OCR frame took ${frameStopwatch.elapsedMilliseconds} ms.',
        );
      }
      _processingFrame = false;
    }
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
    _candidateExpiryTimer?.cancel();
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
        title: const Text('Scan wagon number'),
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
                      onRetry: _retryInitialize,
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
                                onScaleStart: (_) => _gestureStartZoom = _zoom,
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
                              aspectRatio: 0.9,
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
                                    ? 'Place BCN code and full number inside the frame'
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
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

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
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry camera'),
              ),
            ],
          ),
        ),
      );
}
