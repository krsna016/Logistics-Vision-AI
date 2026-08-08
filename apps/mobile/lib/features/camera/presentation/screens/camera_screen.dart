import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../providers/camera_notifier.dart';
import '../providers/camera_state.dart';
import '../providers/inference_notifier.dart';
import '../providers/inference_state.dart';
import '../providers/decision_providers.dart';
import '../../domain/entities/decision_state.dart';
import '../../domain/entities/detection.dart';
import '../widgets/detection_overlay_widget.dart';
import '../../../layer/domain/entities/ai_result.dart';
import '../../../../theme/app_theme.dart';
import '../../../../core/storage/image_storage_service.dart';
import '../../../../core/ai_engine/models/ai_model.dart';
import '../../../../utils/logger.dart';
import 'count_method_screens.dart';

class CameraScreen extends ConsumerStatefulWidget {
  final bool isActive;
  final VoidCallback? onManualSelected;

  const CameraScreen({
    super.key,
    this.isActive = true,
    this.onManualSelected,
  });

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  String? _pickedImagePath;
  final ImagePicker _picker = ImagePicker();
  final _streamKey = GlobalKey<_CameraStreamAdapterState>();
  final _imageStorage = ImageStorageService();
  double _gestureStartZoom = 1.0;
  double _gestureZoom = 1.0;
  bool _isGalleryAnalyzing = false;
  bool _torchOn = false;
  bool _routeCovered = false;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _pickedImagePath = image.path;
          _isGalleryAnalyzing = true;
        });
        AppLogger.info('Custom photo loaded for analysis: ${image.path}');
        ref.read(countingDecisionProvider.notifier).resetAnalyzer();
        await ref
            .read(inferenceNotifierProvider.notifier)
            .processGalleryImage(image.path);
        final detections = ref.read(inferenceNotifierProvider).detections;
        final decisionNotifier = ref.read(countingDecisionProvider.notifier);
        decisionNotifier.acceptGalleryDetections(detections);
        if (mounted) setState(() => _isGalleryAnalyzing = false);
      }
    } catch (e, stack) {
      AppLogger.error('Failed to import photo', e, stack);
      if (mounted) setState(() => _isGalleryAnalyzing = false);
    }
  }

  Future<void> _toggleTorch(CameraController? controller) async {
    if (controller == null || !controller.value.isInitialized) return;
    try {
      final next = !_torchOn;
      await controller.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _torchOn = next);
    } on CameraException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.description ?? 'Flashlight is not available.'),
        ),
      );
    }
  }

  Future<void> _openGallery(CameraController? controller) async {
    if (_torchOn) await _toggleTorch(controller);
    await _pickImage();
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraNotifierProvider);
    final cameraNotifier = ref.read(cameraNotifierProvider.notifier);
    final isGallery = _pickedImagePath != null;
    final inferenceReady = ref.watch(
      inferenceNotifierProvider.select((state) => state.isModelLoaded),
    );
    final inferenceState = isGallery
        ? ref.watch(inferenceNotifierProvider)
        : ref.read(inferenceNotifierProvider);
    final decisionState = isGallery
        ? ref.watch(countingDecisionProvider)
        : ref.read(countingDecisionProvider);
    final decisionNotifier = ref.read(countingDecisionProvider.notifier);
    final routerState = GoRouterState.of(context);
    final truckId = routerState.pathParameters['id'] ?? '';
    final bool isReadyForReview =
        decisionState.status == CountingDecisionState.readyForReview;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ── Layer 0: Edge-to-edge camera/gallery preview ───────────────
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart:
                  !isGallery ? (_) => _gestureStartZoom = _gestureZoom : null,
              onScaleUpdate: !isGallery
                  ? (details) {
                      if (details.scale == 1.0) return;
                      _gestureZoom = (_gestureStartZoom * details.scale)
                          .clamp(1.0, 20.0)
                          .toDouble();
                      cameraNotifier.setZoomLevel(_gestureZoom);
                    }
                  : null,
              child: isGallery
                  ? _GalleryPreview(
                      path: _pickedImagePath!,
                      decisionState: decisionState,
                      detections: inferenceState.detections,
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      reverseDuration: const Duration(milliseconds: 160),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: KeyedSubtree(
                        key: ValueKey(cameraState.status),
                        child: _buildMainContent(
                          context,
                          cameraState,
                          cameraNotifier,
                          inferenceReady && widget.isActive && !_routeCovered,
                        ),
                      ),
                    ),
            ),
          ),

          // ── Layer 1: Simple camera header ──────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _SimpleCameraHeader(
              onManualSelected: widget.onManualSelected ??
                  () => context.pushReplacement(
                        '/trucks/$truckId/manual-count',
                      ),
            ),
          ),

          if (_isGalleryAnalyzing)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xDD101010),
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text('Counting cartons...',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Layer 2: Minimal controls over the camera preview ──────────
          if (cameraState.status == CameraStatus.ready || isGallery)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 28,
              left: 28,
              right: 28,
              child: _CameraOverlayControls(
                isReadyForReview: isReadyForReview,
                isGallery: isGallery,
                torchOn: _torchOn,
                onToggleTorch: isGallery
                    ? null
                    : () => _toggleTorch(cameraState.controller),
                onGallery: () => _openGallery(cameraState.controller),
                onFlipCamera: () {
                  if (isGallery) {
                    setState(() => _pickedImagePath = null);
                  } else if (cameraState.availableCameras.length > 1) {
                    setState(() => _torchOn = false);
                    cameraNotifier.switchCamera();
                  }
                  decisionNotifier.resetAnalyzer();
                },
                onReset: () {
                  setState(() => _pickedImagePath = null);
                  decisionNotifier.resetAnalyzer();
                },
                onReview: isReadyForReview
                    ? () => _navigateToReview(
                          context,
                          truckId,
                          inferenceState,
                          decisionState,
                        )
                    : null,
                onCapture: !isGallery
                    ? () {
                        _captureLayerPhoto(
                          context,
                          truckId,
                          ref.read(inferenceNotifierProvider),
                          ref.read(countingDecisionProvider),
                        );
                      }
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _navigateToReview(BuildContext context, String truckId,
      InferenceState inferenceState, DecisionState decisionState,
      {String? photoPath, int? capturedCount}) async {
    final aiResult = AIResult(
      detections: inferenceState.detections,
      count: capturedCount ??
          (_pickedImagePath != null
              ? inferenceState.detections.length
              : decisionState.stableCount),
      averageConfidence: 0.96,
      processingTimeMs: 15.0,
      modelVersion: 'yolo11n_carton_seg_v1_3',
      inferenceTimestamp: DateTime.now(),
      frameSize: const Size(720, 1280),
    );

    if (mounted) setState(() => _routeCovered = true);
    await context.push('/trucks/$truckId/review', extra: {
      'aiResult': aiResult,
      'photoPath': photoPath ?? _pickedImagePath,
    });
    if (mounted) setState(() => _routeCovered = false);
  }

  Future<void> _captureLayerPhoto(
    BuildContext context,
    String truckId,
    InferenceState inferenceState,
    DecisionState decisionState,
  ) async {
    try {
      final photo = await _streamKey.currentState?.capturePhoto();
      if (photo == null || !context.mounted) return;

      final savedPath = await _imageStorage.saveImage(
        File(photo.path),
        'ai_layer_$truckId',
      );
      if (!context.mounted) return;

      final capturedCount = decisionState.stableCount > 0
          ? decisionState.stableCount
          : inferenceState.detections.length;
      _navigateToReview(
        context,
        truckId,
        inferenceState,
        decisionState,
        photoPath: savedPath,
        capturedCount: capturedCount,
      );
    } catch (e, stack) {
      AppLogger.error('Failed to capture layer photo', e, stack);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not capture the layer photo.')),
        );
      }
    }
  }

  Widget _buildMainContent(
    BuildContext context,
    CameraState state,
    CameraNotifier notifier,
    bool inferenceReady,
  ) {
    switch (state.status) {
      case CameraStatus.initializing:
      case CameraStatus.switching:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text(
                'Connecting to camera hardware...',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ],
          ),
        );

      case CameraStatus.permissionDenied:
        return _CameraErrorState(
          icon: Icons.videocam_off_outlined,
          title: 'Camera Access Required',
          subtitle:
              'Warehouse counting requires camera permission. Please grant access in device settings.',
          buttonLabel: 'Grant Permission',
          onRetry: () => notifier.initialize(),
        );

      case CameraStatus.error:
        return _CameraErrorState(
          icon: Icons.error_outline,
          title: 'Camera Error',
          subtitle:
              state.errorMessage ?? 'An unexpected hardware error occurred.',
          buttonLabel: 'Retry',
          onRetry: () => notifier.initialize(),
        );

      case CameraStatus.ready:
        return _CameraStreamAdapter(
          key: _streamKey,
          controller: state.controller!,
          inferenceReady: inferenceReady,
        );

      case CameraStatus.disposed:
        return const Center(
          child: Text('Camera disconnected.',
              style: TextStyle(color: Colors.white54)),
        );
    }
  }
}

class _SimpleCameraHeader extends StatelessWidget {
  final VoidCallback onManualSelected;

  const _SimpleCameraHeader({
    required this.onManualSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      child: Center(
        child: CountModeSwitcher(
          selectedMode: CountMode.ai,
          onAiSelected: () {},
          onManualSelected: onManualSelected,
        ),
      ),
    );
  }
}

// ─── TOP INFORMATION BAR ─────────────────────────────────────────────────────
// ignore: unused_element
class _CameraTopBar extends StatelessWidget {
  final String wagonNumber;
  final String truckNumber;
  final int layerNumber;
  final int totalCartons;
  final bool isOnline;

  const _CameraTopBar({
    required this.wagonNumber,
    required this.truckNumber,
    required this.layerNumber,
    required this.totalCartons,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xF0000000), Color(0xAA000000), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                tooltip: 'Back',
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints.tightFor(width: 32, height: 32),
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/wagons'),
              ),
              const SizedBox(width: 4),
              // Brand
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset('assets/images/logo.png',
                    width: 18, height: 18, fit: BoxFit.contain),
              ),
              const SizedBox(width: 6),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Vinayak SmartLoad',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                  Text('AI Scanning Mode',
                      style: TextStyle(color: Colors.white54, fontSize: 9)),
                ],
              ),
              const SizedBox(width: 10),
              // Separator
              Container(width: 1, height: 28, color: Colors.white24),
              const SizedBox(width: 10),

              // Context chips
              _TopChip(label: 'WAGON', value: wagonNumber),
              const SizedBox(width: 8),
              _TopChip(label: 'TRUCK', value: truckNumber),
              const SizedBox(width: 8),
              _TopChip(
                  label: 'LAYER',
                  value: '#$layerNumber',
                  valueColor: AppTheme.warningColor),

              const Spacer(),

              // Status indicators
              _TopChip(
                label: isOnline ? 'ONLINE' : 'OFFLINE',
                value: '',
                valueColor:
                    isOnline ? AppTheme.successColor : AppTheme.errorColor,
                compact: true,
                dotColor:
                    isOnline ? AppTheme.successColor : AppTheme.errorColor,
              ),
              const SizedBox(width: 8),
              const Icon(Icons.battery_full, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Text(timeStr,
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool compact;
  final Color? dotColor;

  const _TopChip({
    required this.label,
    required this.value,
    this.valueColor,
    this.compact = false,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
              if (value.isNotEmpty)
                Text(value,
                    style: TextStyle(
                        color: valueColor ?? Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── AI STATUS PANEL ─────────────────────────────────────────────────────────
// ignore: unused_element
class _AIStatusPanel extends StatelessWidget {
  final dynamic inferenceState;
  final DecisionState decisionState;

  const _AIStatusPanel(
      {required this.inferenceState, required this.decisionState});

  String get _statusLabel {
    switch (decisionState.status) {
      case CountingDecisionState.collecting:
        return 'Collecting';
      case CountingDecisionState.analyzing:
        return 'Analyzing';
      case CountingDecisionState.stable:
      case CountingDecisionState.readyForReview:
        return 'Ready ✓';
      case CountingDecisionState.unstable:
        return 'Unstable';
      case CountingDecisionState.rejected:
      case CountingDecisionState.error:
        return 'Error';
    }
  }

  Color get _statusColor {
    switch (decisionState.status) {
      case CountingDecisionState.readyForReview:
      case CountingDecisionState.stable:
        return AppTheme.successColor;
      case CountingDecisionState.collecting:
      case CountingDecisionState.analyzing:
        return AppTheme.warningColor;
      default:
        return AppTheme.errorColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final conf = (decisionState.averageConfidence * 100).toInt();
    final stability = (decisionState.stabilityScore * 100).toInt();

    return Container(
      width: MediaQuery.sizeOf(context).width *
          (MediaQuery.sizeOf(context).width < 360 ? 0.42 : 0.46),
      constraints: const BoxConstraints(maxWidth: 168),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xDD0D1B2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _statusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: _statusColor.withValues(alpha: 0.6),
                        blurRadius: 4)
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Text('AI ENGINE',
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8)),
              const Spacer(),
              const Text(AIModel.activeLabel,
                  style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 10, color: Color(0xFF2A3F52)),
          Row(
            children: [
              _AIMetric(
                  label: 'CONF',
                  value: '$conf%',
                  color: conf > 85
                      ? AppTheme.successColor
                      : AppTheme.warningColor),
              const SizedBox(width: 8),
              _AIMetric(
                  label: 'STAB',
                  value: '$stability%',
                  color: stability > 80
                      ? AppTheme.successColor
                      : AppTheme.warningColor),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const _AIMetric(label: 'MODEL', value: 'v1.3'),
              const SizedBox(width: 8),
              _AIMetric(
                  label: 'STATUS', value: _statusLabel, color: _statusColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _AIMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _AIMetric({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5)),
          Text(value,
              style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ─── LIVE COUNTER BAR ─────────────────────────────────────────────────────────
// ignore: unused_element
class _LiveCounterBar extends StatelessWidget {
  final int detectedCount;
  final double confidence;
  final double stabilityScore;
  final CountingDecisionState status;
  final String recommendedAction;
  final List<String> warnings;
  final double qualityScore;

  const _LiveCounterBar({
    required this.detectedCount,
    required this.confidence,
    required this.stabilityScore,
    required this.status,
    required this.recommendedAction,
    required this.warnings,
    required this.qualityScore,
  });

  Color get _borderColor {
    switch (status) {
      case CountingDecisionState.readyForReview:
      case CountingDecisionState.stable:
        return AppTheme.successColor;
      case CountingDecisionState.collecting:
      case CountingDecisionState.analyzing:
        return AppTheme.warningColor;
      default:
        return AppTheme.errorColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final confPct = (confidence * 100).toInt();
    final stabPct = (stabilityScore * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Warning pill if present
        if (warnings.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    warnings.first,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xEE0D1B2A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _borderColor.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CountCol('DETECTED', '$detectedCount',
                      color: Colors.white, large: true),
                  _vDivider(),
                  _CountCol('CONFIDENCE', '$confPct%',
                      color: confPct > 85
                          ? AppTheme.successColor
                          : confPct > 60
                              ? AppTheme.warningColor
                              : AppTheme.errorColor),
                  _vDivider(),
                  _CountCol('STABILITY', '$stabPct%',
                      color: stabPct > 80
                          ? AppTheme.successColor
                          : AppTheme.warningColor),
                  _vDivider(),
                  const _CountCol('MODEL', AIModel.activeLabel,
                      color: AppTheme.primaryColor),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: stabilityScore,
                  minHeight: 4,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(_borderColor),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                recommendedAction,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 32,
        color: Colors.white12,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );
}

class _CountCol extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool large;

  const _CountCol(this.label, this.value, {this.color, this.large = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5)),
        const SizedBox(height: 2),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            value,
            key: ValueKey(value),
            style: TextStyle(
                color: color ?? Colors.white,
                fontSize: large ? 24 : 14,
                fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

// ─── ALIGNMENT GUIDE ─────────────────────────────────────────────────────────
// ignore: unused_element
class _AlignmentGuide extends StatelessWidget {
  final bool isVisible;

  const _AlignmentGuide({required this.isVisible});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _GuidePainter()),
          ),
          Positioned(
            bottom: 280,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.crop_free, color: Colors.white70, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Align the front layer inside the guide',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.45),
      width: size.width * 0.82,
      height: size.height * 0.48,
    );

    // Semi-transparent fill
    canvas.drawRect(
      rect,
      Paint()..color = const Color(0xFF1565C0).withValues(alpha: 0.05),
    );

    // Dashed border
    final dashPaint = Paint()
      ..color = const Color(0xFF1565C0).withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    _drawDashedRect(canvas, rect, dashPaint);

    // Corner brackets
    final cornerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const double cLen = 20;

    // Top-left
    canvas.drawLine(rect.topLeft, rect.topLeft.translate(cLen, 0), cornerPaint);
    canvas.drawLine(rect.topLeft, rect.topLeft.translate(0, cLen), cornerPaint);
    // Top-right
    canvas.drawLine(
        rect.topRight, rect.topRight.translate(-cLen, 0), cornerPaint);
    canvas.drawLine(
        rect.topRight, rect.topRight.translate(0, cLen), cornerPaint);
    // Bottom-left
    canvas.drawLine(
        rect.bottomLeft, rect.bottomLeft.translate(cLen, 0), cornerPaint);
    canvas.drawLine(
        rect.bottomLeft, rect.bottomLeft.translate(0, -cLen), cornerPaint);
    // Bottom-right
    canvas.drawLine(
        rect.bottomRight, rect.bottomRight.translate(-cLen, 0), cornerPaint);
    canvas.drawLine(
        rect.bottomRight, rect.bottomRight.translate(0, -cLen), cornerPaint);
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    const dashLen = 12.0;
    const gapLen = 8.0;

    void drawDashedLine(Offset start, Offset end) {
      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;
      final total = math.sqrt(dx * dx + dy * dy);
      final length = total < 1 ? 1.0 : total;
      final nx = dx / length;
      final ny = dy / length;
      double pos = 0;
      bool draw = true;
      while (pos < length) {
        final segLen = draw
            ? (pos + dashLen < length ? dashLen : length - pos)
            : (pos + gapLen < length ? gapLen : length - pos);
        if (draw) {
          canvas.drawLine(
            Offset(start.dx + nx * pos, start.dy + ny * pos),
            Offset(
                start.dx + nx * (pos + segLen), start.dy + ny * (pos + segLen)),
            paint,
          );
        }
        pos += segLen;
        draw = !draw;
      }
    }

    drawDashedLine(rect.topLeft, rect.topRight);
    drawDashedLine(rect.topRight, rect.bottomRight);
    drawDashedLine(rect.bottomRight, rect.bottomLeft);
    drawDashedLine(rect.bottomLeft, rect.topLeft);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── CAMERA OVERLAY CONTROLS ─────────────────────────────────────────────────
class _CameraOverlayControls extends StatefulWidget {
  final bool isReadyForReview;
  final bool isGallery;
  final bool torchOn;
  final VoidCallback? onToggleTorch;
  final VoidCallback onGallery;
  final VoidCallback onFlipCamera;
  final VoidCallback onReset;
  final VoidCallback? onCapture;
  final VoidCallback? onReview;

  const _CameraOverlayControls({
    required this.isReadyForReview,
    required this.isGallery,
    required this.torchOn,
    required this.onToggleTorch,
    required this.onGallery,
    required this.onFlipCamera,
    required this.onReset,
    required this.onCapture,
    required this.onReview,
  });

  @override
  State<_CameraOverlayControls> createState() => _CameraOverlayControlsState();
}

class _CameraOverlayControlsState extends State<_CameraOverlayControls>
    with SingleTickerProviderStateMixin {
  late final AnimationController _menuController;
  bool _menuOpen = false;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 190),
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() => _menuOpen = !_menuOpen);
    if (_menuOpen) {
      _menuController.forward();
    } else {
      _menuController.reverse();
    }
  }

  void _runAndClose(VoidCallback action) {
    action();
    if (_menuOpen) _toggleMenu();
  }

  Widget _menuOption({
    required int index,
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final animation = CurvedAnimation(
      parent: _menuController,
      curve:
          Interval(index * 0.1, 0.78 + index * 0.1, curve: Curves.easeOutBack),
      reverseCurve: Curves.easeInCubic,
    );

    return Positioned(
      bottom: 62.0 + index * 60,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => IgnorePointer(
          ignoring: animation.value < 0.95,
          child: Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 16 * (1 - animation.value)),
              child: Transform.scale(
                scale: 0.72 + 0.28 * animation.value,
                child: child,
              ),
            ),
          ),
        ),
        child: _RoundCameraButton(
          icon: icon,
          tooltip: tooltip,
          onTap: () => _runAndClose(onTap),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shutterAction = widget.isGallery
        ? (widget.isReadyForReview ? widget.onReview : null)
        : widget.onCapture;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _RoundCameraButton(
          icon:
              widget.torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
          tooltip: widget.torchOn ? 'Turn flash off' : 'Turn flash on',
          onTap: widget.onToggleTorch,
        ),
        Semantics(
          button: true,
          label: widget.isGallery ? 'Review count' : 'Capture layer',
          child: GestureDetector(
            onTap: shutterAction,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 82,
              height: 82,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.45),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: shutterAction == null
                      ? Colors.white38
                      : (widget.isGallery
                          ? AppTheme.successColor
                          : Colors.white),
                ),
                child: widget.isGallery
                    ? const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 30)
                    : null,
              ),
            ),
          ),
        ),
        SizedBox(
          width: 52,
          height: 232,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              _menuOption(
                index: 2,
                icon: Icons.photo_library_outlined,
                tooltip: 'Gallery',
                onTap: widget.onGallery,
              ),
              _menuOption(
                index: 1,
                icon: widget.isGallery
                    ? Icons.camera_alt_outlined
                    : Icons.flip_camera_ios_outlined,
                tooltip: widget.isGallery ? 'Camera' : 'Flip camera',
                onTap: widget.onFlipCamera,
              ),
              _menuOption(
                index: 0,
                icon: Icons.refresh_rounded,
                tooltip: 'Reset',
                onTap: widget.onReset,
              ),
              _RoundCameraButton(
                icon: _menuOpen ? Icons.close_rounded : Icons.more_vert_rounded,
                tooltip:
                    _menuOpen ? 'Close camera options' : 'More camera options',
                onTap: _toggleMenu,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundCameraButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _RoundCameraButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: onTap == null ? 0.42 : 1,
      duration: const Duration(milliseconds: 160),
      child: Semantics(
        button: true,
        label: tooltip,
        child: Material(
          color: Colors.black.withValues(alpha: 0.58),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 52,
              height: 52,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 170),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  icon,
                  key: ValueKey(icon.codePoint),
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── CAMERA ERROR STATE ───────────────────────────────────────────────────────
class _CameraErrorState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onRetry;

  const _CameraErrorState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: AppTheme.errorColor),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(subtitle,
                style: const TextStyle(
                    color: Colors.white60, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(buttonLabel),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── GALLERY PREVIEW ─────────────────────────────────────────────────────────
class _GalleryPreview extends StatefulWidget {
  final String path;
  final DecisionState decisionState;
  final List<Detection> detections;

  const _GalleryPreview({
    required this.path,
    required this.decisionState,
    required this.detections,
  });

  @override
  State<_GalleryPreview> createState() => _GalleryPreviewState();
}

class _GalleryPreviewState extends State<_GalleryPreview> {
  Size _imageSize = const Size(640, 640);

  @override
  void initState() {
    super.initState();
    _loadImageSize();
  }

  Future<void> _loadImageSize() async {
    try {
      final bytes = await File(widget.path).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded != null && mounted) {
        setState(() {
          _imageSize = Size(
            decoded.width.toDouble(),
            decoded.height.toDouble(),
          );
        });
      }
    } catch (_) {
      // Keep the square fallback if the image dimensions are unavailable.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(File(widget.path), fit: BoxFit.cover),
        DetectionOverlayWidget(
          detections: widget.detections,
          cameraSize: _imageSize,
          fit: BoxFit.cover,
          showLabels: false,
        ),
      ],
    );
  }
}

// ─── CAMERA STREAM ADAPTER ────────────────────────────────────────────────────
class _CameraStreamAdapter extends ConsumerStatefulWidget {
  final CameraController controller;
  final bool inferenceReady;

  const _CameraStreamAdapter({
    super.key,
    required this.controller,
    required this.inferenceReady,
  });

  @override
  ConsumerState<_CameraStreamAdapter> createState() =>
      _CameraStreamAdapterState();
}

class _CameraStreamAdapterState extends ConsumerState<_CameraStreamAdapter> {
  bool _isStreaming = false;
  bool _isStarting = false;
  bool _hasReceivedFrame = false;

  @override
  void initState() {
    super.initState();
    unawaited(_startStream());
  }

  @override
  void didUpdateWidget(covariant _CameraStreamAdapter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _hasReceivedFrame = false;
      unawaited(_replaceStream(oldWidget.controller));
    }
  }

  Future<void> _replaceStream(CameraController oldController) async {
    await _stopStream(oldController);
    if (mounted) await _startStream();
  }

  Future<void> _startStream() async {
    if (_isStreaming || _isStarting) return;
    _isStarting = true;
    final controller = widget.controller;
    try {
      final notifier = ref.read(inferenceNotifierProvider.notifier);
      await controller.startImageStream((image) {
        if (mounted) {
          if (!_hasReceivedFrame) {
            setState(() => _hasReceivedFrame = true);
          }
          if (widget.inferenceReady) notifier.processImageFrame(image);
        }
      });
      if (!mounted || !identical(controller, widget.controller)) {
        await controller.stopImageStream();
        return;
      }
      _isStreaming = true;
    } catch (e, stack) {
      AppLogger.error('Failed to start camera frame stream', e, stack);
    } finally {
      _isStarting = false;
    }
  }

  Future<void> _stopStream(CameraController controller) async {
    if (!_isStreaming && !_isStarting) return;
    _isStreaming = false;
    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } catch (e, stack) {
      AppLogger.error('Failed to halt camera stream', e, stack);
    }
  }

  Future<XFile?> capturePhoto() async {
    final controller = widget.controller;
    if (!controller.value.isInitialized) return null;

    try {
      if (_isStreaming) {
        await controller.stopImageStream();
        _isStreaming = false;
      }
      final photo = await controller.takePicture();
      await _startStream();
      return photo;
    } catch (e, stack) {
      AppLogger.error('Failed to capture camera photo', e, stack);
      await _startStream();
      return null;
    }
  }

  @override
  void dispose() {
    unawaited(_stopStream(widget.controller));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.controller.value.previewSize;
    final cameraSize = size == null
        ? const Size(720, 1280)
        : size.width > size.height
            ? Size(size.height, size.width)
            : Size(size.width, size.height);

    // CameraPreview applies the platform-specific rotation and aspect-ratio
    // transform internally. Keep the overlay as its child so its canvas is
    // exactly the same rectangle as the displayed camera frame.
    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: cameraSize.width,
            height: cameraSize.height,
            child: CameraPreview(
              widget.controller,
              child: Consumer(
                builder: (context, ref, child) {
                  final detections = ref.watch(
                    inferenceNotifierProvider.select(
                      (state) => state.detections,
                    ),
                  );
                  return Positioned.fill(
                    child: RepaintBoundary(
                      child: DetectionOverlayWidget(
                        detections: detections,
                        cameraSize: cameraSize,
                        fit: BoxFit.fill,
                        showLabels: false,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (!_hasReceivedFrame)
          const ColoredBox(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Starting Full HD camera...',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
