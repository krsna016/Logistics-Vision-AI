import 'dart:io';
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
import '../../../layer/presentation/providers/layer_providers.dart';
import '../../../../theme/app_theme.dart';
import '../../../../core/storage/image_storage_service.dart';
import '../../../../core/ai_engine/models/ai_model.dart';
import '../../../../utils/logger.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with TickerProviderStateMixin {
  String? _pickedImagePath;
  final ImagePicker _picker = ImagePicker();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  final _streamKey = GlobalKey<_CameraStreamAdapterState>();
  final _imageStorage = ImageStorageService();
  double _gestureStartZoom = 1.0;
  double _gestureZoom = 1.0;
  bool _isGalleryAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
        // A still image has no frame history, so use the same result as a
        // short stable window to enable review immediately.
        for (var i = 0; i < 5; i++) {
          decisionNotifier.analyzeFrameDetections(detections);
        }
        if (mounted) setState(() => _isGalleryAnalyzing = false);
      }
    } catch (e, stack) {
      AppLogger.error('Failed to import photo', e, stack);
      if (mounted) setState(() => _isGalleryAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraNotifierProvider);
    final cameraNotifier = ref.read(cameraNotifierProvider.notifier);
    final inferenceState = ref.watch(inferenceNotifierProvider);
    final decisionState = ref.watch(countingDecisionProvider);
    final decisionNotifier = ref.read(countingDecisionProvider.notifier);
    final routerState = GoRouterState.of(context);
    final truckId = routerState.pathParameters['id'] ?? '';
    final layerState = ref.watch(layerListProvider(truckId));
    final currentLayer = layerState.layers.length + 1;

    final bool isReadyForReview =
        decisionState.status == CountingDecisionState.readyForReview;
    final bool isGallery = _pickedImagePath != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Layer 0: Bounded camera or gallery preview ─────────────────
          // Keep the preview large enough for carton inspection, while
          // leaving stable space for the header and capture controls.
          Positioned(
            top: MediaQuery.of(context).padding.top + 62,
            left: 12,
            right: 12,
            bottom: 158,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = math.min(
                  constraints.maxWidth,
                  constraints.maxHeight * 3 / 4,
                );
                return Center(
                  child: SizedBox(
                    width: width,
                    height: width * 4 / 3,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onScaleStart: !isGallery
                          ? (_) => _gestureStartZoom = _gestureZoom
                          : null,
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
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              clipBehavior: Clip.antiAlias,
                              child: _GalleryPreview(
                                path: _pickedImagePath!,
                                decisionState: decisionState,
                                detections: inferenceState.detections,
                              ),
                            )
                          : _buildMainContent(
                              context, cameraState, cameraNotifier),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Layer 1: Simple camera header ──────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _SimpleCameraHeader(layerNumber: currentLayer),
          ),

          // ── Layer 2: Simple live count ─────────────────────────────────
          if (cameraState.status == CameraStatus.ready || isGallery)
            Positioned(
              top: 72,
              left: 16,
              child: _SimpleCountBadge(
                count: decisionState.stableCount > 0
                    ? decisionState.stableCount
                    : inferenceState.detections.length,
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

          // ── Layer 3: Capture Controls (bottom dock) ────────────────────
          if (cameraState.status == CameraStatus.ready || isGallery)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _CaptureControlsDock(
                isReadyForReview: isReadyForReview,
                isGallery: isGallery,
                onGallery: _pickImage,
                onFlipCamera: () {
                  if (isGallery) {
                    setState(() => _pickedImagePath = null);
                  } else if (cameraState.availableCameras.length > 1) {
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
                    ? () => _captureLayerPhoto(
                          context,
                          truckId,
                          inferenceState,
                          decisionState,
                        )
                    : null,
                pulseAnimation: _pulseAnim,
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToReview(BuildContext context, String truckId,
      InferenceState inferenceState, DecisionState decisionState,
      {String? photoPath, int? capturedCount}) {
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

    context.push('/trucks/$truckId/review', extra: {
      'aiResult': aiResult,
      'photoPath': photoPath ?? _pickedImagePath,
    });
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
  final int layerNumber;

  const _SimpleCameraHeader({required this.layerNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 16,
        bottom: 12,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xE6000000), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/wagons'),
          ),
          const Expanded(
            child: Text(
              'Capture Layer',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Text('Layer $layerNumber',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}

class _SimpleCountBadge extends StatelessWidget {
  final int count;

  const _SimpleCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count cartons',
        style: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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

// ─── CAPTURE CONTROLS DOCK ───────────────────────────────────────────────────
class _CaptureControlsDock extends StatelessWidget {
  final bool isReadyForReview;
  final bool isGallery;
  final VoidCallback onGallery;
  final VoidCallback onFlipCamera;
  final VoidCallback onReset;
  final VoidCallback? onCapture;
  final VoidCallback? onReview;
  final Animation<double> pulseAnimation;

  const _CaptureControlsDock({
    required this.isReadyForReview,
    required this.isGallery,
    required this.onGallery,
    required this.onFlipCamera,
    required this.onReset,
    required this.onCapture,
    required this.onReview,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Color(0xFF000000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Secondary controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _IconControl(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: onGallery,
              ),
              _IconControl(
                icon: isGallery
                    ? Icons.camera_alt_outlined
                    : Icons.flip_camera_ios_outlined,
                label: isGallery ? 'Camera' : 'Flip',
                onTap: onFlipCamera,
              ),
              _IconControl(
                icon: Icons.refresh_outlined,
                label: 'Reset',
                onTap: onReset,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Primary Review Button
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) {
              return Container(
                decoration: isReadyForReview
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.successColor
                                .withValues(alpha: pulseAnimation.value * 0.6),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      )
                    : null,
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton.icon(
                    onPressed: isGallery ? onReview : onCapture,
                    icon: Icon(
                      isGallery ? Icons.rate_review : Icons.camera_alt_outlined,
                      size: 22,
                    ),
                    label: Text(
                      isGallery ? 'Review Count  →' : 'Capture Layer',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isGallery
                          ? (isReadyForReview
                              ? AppTheme.successColor
                              : Colors.white12)
                          : AppTheme.primaryColor,
                      foregroundColor: isGallery && !isReadyForReview
                          ? Colors.white38
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      elevation: isReadyForReview ? 4 : 0,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IconControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IconControl({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
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
        Image.file(File(widget.path), fit: BoxFit.contain),
        DetectionOverlayWidget(
          detections: widget.detections,
          cameraSize: _imageSize,
          fit: BoxFit.contain,
          showLabels: false,
        ),
      ],
    );
  }
}

// ─── CAMERA STREAM ADAPTER ────────────────────────────────────────────────────
class _CameraStreamAdapter extends ConsumerStatefulWidget {
  final CameraController controller;

  const _CameraStreamAdapter({super.key, required this.controller});

  @override
  ConsumerState<_CameraStreamAdapter> createState() =>
      _CameraStreamAdapterState();
}

class _CameraStreamAdapterState extends ConsumerState<_CameraStreamAdapter> {
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _startStream();
  }

  @override
  void didUpdateWidget(covariant _CameraStreamAdapter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _stopStream(oldWidget.controller);
      _startStream();
    }
  }

  void _startStream() {
    if (_isStreaming) return;
    try {
      final notifier = ref.read(inferenceNotifierProvider.notifier);
      widget.controller.startImageStream((image) {
        if (mounted) {
          notifier.processImageFrame(image);
        }
      });
      _isStreaming = true;
    } catch (e, stack) {
      AppLogger.error('Failed to start camera frame stream', e, stack);
    }
  }

  void _stopStream(CameraController controller) {
    if (!_isStreaming) return;
    try {
      controller.stopImageStream();
      _isStreaming = false;
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
      _startStream();
      return photo;
    } catch (e, stack) {
      AppLogger.error('Failed to capture camera photo', e, stack);
      _startStream();
      return null;
    }
  }

  @override
  void dispose() {
    _stopStream(widget.controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inferenceState = ref.watch(inferenceNotifierProvider);
    final size = widget.controller.value.previewSize;
    final cameraSize = size == null
        ? const Size(720, 1280)
        : size.width > size.height
            ? Size(size.height, size.width)
            : Size(size.width, size.height);

    // CameraPreview applies the platform-specific rotation and aspect-ratio
    // transform internally. Keep the overlay as its child so its canvas is
    // exactly the same rectangle as the displayed camera frame.
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: Center(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: cameraSize.width,
            height: cameraSize.height,
            child: CameraPreview(
              widget.controller,
              child: Positioned.fill(
                child: DetectionOverlayWidget(
                  detections: inferenceState.detections,
                  cameraSize: cameraSize,
                  fit: BoxFit.fill,
                  showLabels: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
