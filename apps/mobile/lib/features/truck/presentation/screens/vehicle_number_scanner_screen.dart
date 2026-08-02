import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class VehicleNumberScannerScreen extends StatefulWidget {
  const VehicleNumberScannerScreen({super.key});

  @override
  State<VehicleNumberScannerScreen> createState() =>
      _VehicleNumberScannerScreenState();
}

class _VehicleNumberScannerScreenState extends State<VehicleNumberScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  final TextEditingController _resultController = TextEditingController();

  File? _capturedImage;
  String _rawText = '';
  String? _error;
  bool _initializing = true;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _openCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _resultController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed && _capturedImage == null) {
      _openCamera();
    }
  }

  Future<void> _openCamera() async {
    if (!mounted) return;
    setState(() {
      _initializing = true;
      _error = null;
      _capturedImage = null;
      _rawText = '';
      _resultController.clear();
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw StateError('No camera is available on this phone.');
      }
      final camera = cameras.firstWhere(
        (item) => item.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await _cameraController?.dispose();
      setState(() {
        _cameraController = controller;
        _initializing = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error =
            'Camera could not start. Check camera permission and try again.';
        _rawText = error.toString();
      });
    }
  }

  Future<void> _captureAndRead() async {
    final controller = _cameraController;
    if (_capturing || controller == null || !controller.value.isInitialized) {
      return;
    }

    setState(() {
      _capturing = true;
      _error = null;
      _rawText = '';
    });

    try {
      final photo = await controller.takePicture();
      final image = File(photo.path);
      await controller.pausePreview();
      if (!mounted) return;
      setState(() => _capturedImage = image);

      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      try {
        final recognized = await recognizer.processImage(
          InputImage.fromFilePath(image.path),
        );
        if (!mounted) return;
        final number = _findVehicleNumber(recognized);
        setState(() {
          _rawText = recognized.text.trim();
          if (number != null) {
            _resultController.text = number;
          } else {
            _error = recognized.text.trim().isEmpty
                ? 'No plate text found. Retake with the plate inside the frame.'
                : 'Text was found, but no vehicle number pattern was detected. You can edit the field below.';
          }
        });
      } finally {
        await recognizer.close();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error =
            'Could not capture or read the plate. Please retake the photo.';
        _rawText = error.toString();
      });
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  String? _findVehicleNumber(RecognizedText recognized) {
    final candidates = <String>[];
    final parts = <String>[
      recognized.text,
      for (final block in recognized.blocks) ...[
        block.text,
        for (final line in block.lines) line.text,
      ],
    ];

    for (final part in parts) {
      final normalized = _normalize(part);
      if (normalized.isEmpty) continue;
      for (final match in _registrationPattern.allMatches(normalized)) {
        candidates.add(match.group(0)!);
      }
      final compact = normalized.replaceAll(RegExp(r'[^A-Z0-9]'), '');
      if (_looksLikeRegistration(compact)) candidates.add(compact);
    }

    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => b.length.compareTo(a.length));
    return candidates.first;
  }

  String _normalize(String value) => value
      .toUpperCase()
      .replaceAll('|', 'I')
      .replaceAll(RegExp(r'[^A-Z0-9\s-]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  bool _looksLikeRegistration(String value) {
    return _registrationPattern.hasMatch(value) ||
        RegExp(r'^[A-Z]{2}\d{1,2}[A-Z]{0,3}\d{3,4}$').hasMatch(value);
  }

  static final RegExp _registrationPattern = RegExp(
    r'[A-Z]{2}\s*\d{1,2}\s*[A-Z]{0,3}\s*\d{3,4}',
  );

  void _useResult() {
    final value = _resultController.text.trim().toUpperCase();
    if (value.isEmpty) {
      setState(() => _error = 'Capture a plate or enter a vehicle number.');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraController;
    final cameraReady = controller?.value.isInitialized == true;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Capture vehicle number'),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: _capturedImage != null
            ? _buildReviewView()
            : Stack(
                fit: StackFit.expand,
                children: [
                  if (cameraReady) CameraPreview(controller!),
                  if (_initializing)
                    const Center(child: CircularProgressIndicator()),
                  if (!_initializing && !cameraReady) _buildCameraError(),
                  if (cameraReady) ...[
                    const _PlateFrameOverlay(),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 24,
                      child: Column(
                        children: [
                          const Text(
                            'Align the yellow plate inside the frame',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              shadows: [Shadow(blurRadius: 4)],
                            ),
                          ),
                          const SizedBox(height: 14),
                          FloatingActionButton.large(
                            onPressed: _capturing ? null : _captureAndRead,
                            child: _capturing
                                ? const CircularProgressIndicator()
                                : const Icon(Icons.camera_alt, size: 34),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildReviewView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(_capturedImage!, height: 260, fit: BoxFit.contain),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _resultController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Recognized vehicle number',
            hintText: 'Example: AS01FC0451',
            border: OutlineInputBorder(),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: TextStyle(color: Colors.orange.shade300)),
        ],
        const SizedBox(height: 14),
        FilledButton(
          onPressed: _capturing ? null : _useResult,
          child: const Text('Use this vehicle number'),
        ),
        OutlinedButton.icon(
          onPressed: _capturing ? null : _openCamera,
          icon: const Icon(Icons.refresh),
          label: const Text('Retake plate photo'),
        ),
        if (_rawText.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Text('OCR text found',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          SelectableText(_rawText),
        ],
      ],
    );
  }

  Widget _buildCameraError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined, size: 56),
            const SizedBox(height: 12),
            Text(_error ?? 'Camera unavailable', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _openCamera,
              icon: const Icon(Icons.refresh),
              label: const Text('Try camera again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlateFrameOverlay extends StatelessWidget {
  const _PlateFrameOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _PlateFramePainter(),
      ),
    );
  }
}

class _PlateFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final frameWidth = size.width * 0.84;
    final frameHeight = frameWidth * 0.28;
    final frame = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.43),
        width: frameWidth,
        height: frameHeight,
      ),
      const Radius.circular(16),
    );
    canvas.drawColor(Colors.black.withValues(alpha: 0.28), BlendMode.srcOver);
    final clearPaint = Paint()..blendMode = BlendMode.clear;
    canvas.drawRRect(frame, clearPaint);
    final border = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRRect(frame, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
