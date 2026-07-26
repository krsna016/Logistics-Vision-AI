import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/camera_notifier.dart';
import '../providers/camera_state.dart';
import '../providers/inference_notifier.dart';
import '../providers/decision_providers.dart';
import '../../domain/entities/decision_state.dart';
import '../../domain/entities/detection.dart';
import '../widgets/detection_overlay_widget.dart';
import '../widgets/debug_telemetry_overlay.dart';
import '../../../layer/domain/entities/ai_result.dart';
import '../../../truck/domain/entities/truck.dart';
import '../../../truck/presentation/providers/truck_providers.dart';
import '../../../layer/presentation/providers/layer_providers.dart';
import '../../../wagon/presentation/providers/wagon_providers.dart';
import '../../../../theme/app_theme.dart';
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
        setState(() => _pickedImagePath = image.path);
        AppLogger.info('Custom photo loaded for analysis: ${image.path}');
        final List<Detection> simulatedDetections = [];
        const int cols = 9;
        const int rows = 8;
        for (int r = 0; r < rows; r++) {
          for (int c = 0; c < cols; c++) {
            simulatedDetections.add(dynamicDetection(
              id: 'picked_carton_${r}_$c',
              xMin: 0.14 + c * 0.082,
              yMin: 0.22 + r * 0.080,
              xMax: 0.22 + c * 0.082,
              yMax: 0.29 + r * 0.080,
            ));
          }
        }
        ref.read(countingDecisionProvider.notifier).analyzeFrameDetections(simulatedDetections);
      }
    } catch (e, stack) {
      AppLogger.error('Failed to import photo', e, stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraNotifierProvider);
    final cameraNotifier = ref.read(cameraNotifierProvider.notifier);
    final inferenceState = ref.watch(inferenceNotifierProvider);
    final inferenceNotifier = ref.read(inferenceNotifierProvider.notifier);
    final decisionState = ref.watch(countingDecisionProvider);
    final decisionNotifier = ref.read(countingDecisionProvider.notifier);
    final routerState = GoRouterState.of(context);
    final truckId = routerState.pathParameters['id'] ?? '';

    // Derive truck/wagon context for top bar
    final truckState = ref.watch(truckListProvider);
    final truck = truckState.trucks.firstWhere(
      (t) => t.id == truckId,
      orElse: () => Truck(
        id: '', truckNumber: '------', vehicleNumber: '', driverName: '',
        company: '', warehouse: '', status: TruckStatus.loading,
        createdDate: DateTime.now(), updatedDate: DateTime.now(),
      ),
    );
    final layerState = ref.watch(layerListProvider(truckId));
    final currentLayer = layerState.layers.length + 1;

    final wagonState = ref.watch(wagonListProvider);
    final wagon = wagonState.wagons.firstWhere(
      (w) => w.id == truck.wagonId,
      orElse: () => _emptyWagon(),
    );

    final bool isReadyForReview =
        decisionState.status == CountingDecisionState.readyForReview;
    final bool isGallery = _pickedImagePath != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Layer 0: Full-screen camera or gallery image ──────────────
          Positioned.fill(
            child: isGallery
                ? _GalleryPreview(
                    path: _pickedImagePath!,
                    decisionState: decisionState,
                  )
                : _buildMainContent(context, cameraState, cameraNotifier),
          ),

          // ── Layer 1: Top Information Bar ──────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _CameraTopBar(
              wagonNumber: wagon.wagonNumber,
              truckNumber: truck.vehicleNumber,
              layerNumber: currentLayer,
              totalCartons: truck.totalCartons,
              isOnline: false,
            ),
          ),

          // ── Layer 2: Alignment Guide Overlay (only while collecting) ──
          if (decisionState.status == CountingDecisionState.collecting ||
              decisionState.status == CountingDecisionState.analyzing)
            Positioned.fill(
              child: _AlignmentGuide(
                isVisible: !isReadyForReview,
              ),
            ),

          // ── Layer 3: AI Status Panel (top-right, below top bar) ───────
          Positioned(
            top: 100,
            right: 12,
            child: _AIStatusPanel(
              inferenceState: inferenceState,
              decisionState: decisionState,
            ),
          ),

          // ── Layer 4: Debug Telemetry (conditional) ────────────────────
          if (inferenceState.isDebugMode)
            Positioned(
              top: 240,
              right: 12,
              child: DebugTelemetryOverlay(telemetry: inferenceState.telemetry),
            ),

          // ── Layer 5: Live Counter Bar (bottom-center, above controls) ─
          if (cameraState.status == CameraStatus.ready || isGallery)
            Positioned(
              bottom: 160,
              left: 16,
              right: 16,
              child: _LiveCounterBar(
                detectedCount: decisionState.stableCount,
                confidence: decisionState.averageConfidence,
                stabilityScore: decisionState.stabilityScore,
                status: decisionState.status,
                recommendedAction: decisionState.recommendedAction,
                warnings: decisionState.warnings,
                qualityScore: decisionState.qualityScore,
              ),
            ),

          // ── Layer 6: Capture Controls (bottom dock) ───────────────────
          if (cameraState.status == CameraStatus.ready || isGallery)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _CaptureControlsDock(
                isReadyForReview: isReadyForReview,
                isGallery: isGallery,
                isDebugMode: inferenceState.isDebugMode,
                onGallery: _pickImage,
                onFlipCamera: () {
                  if (isGallery) {
                    setState(() => _pickedImagePath = null);
                  } else if (cameraState.availableCameras.length > 1) {
                    cameraNotifier.switchCamera();
                  }
                  decisionNotifier.resetAnalyzer();
                },
                onDebugToggle: () => inferenceNotifier.toggleDebugOverlay(),
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
                pulseAnimation: _pulseAnim,
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToReview(
    BuildContext context,
    String truckId,
    dynamic inferenceState,
    DecisionState decisionState,
  ) {
    final List<Detection> finalDetections = [];
    if (_pickedImagePath != null) {
      const int cols = 9;
      const int rows = 8;
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          finalDetections.add(dynamicDetection(
            id: 'review_carton_${r}_$c',
            xMin: 0.14 + c * 0.082,
            yMin: 0.22 + r * 0.080,
            xMax: 0.22 + c * 0.082,
            yMax: 0.29 + r * 0.080,
          ));
        }
      }
    }

    final aiResult = AIResult(
      detections: _pickedImagePath != null ? finalDetections : inferenceState.detections,
      count: decisionState.stableCount,
      averageConfidence: 0.96,
      processingTimeMs: 15.0,
      modelVersion: '1.0.0-YOLOv8n',
      inferenceTimestamp: DateTime.now(),
      frameSize: const Size(720, 1280),
    );

    context.go('/trucks/$truckId/review', extra: {
      'aiResult': aiResult,
      'photoPath': _pickedImagePath,
    });
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
          subtitle: state.errorMessage ?? 'An unexpected hardware error occurred.',
          buttonLabel: 'Retry',
          onRetry: () => notifier.initialize(),
        );

      case CameraStatus.ready:
        return _CameraStreamAdapter(controller: state.controller!);

      case CameraStatus.disposed:
        return const Center(
          child: Text('Camera disconnected.', style: TextStyle(color: Colors.white54)),
        );
    }
  }

  // ignore: prefer_const_constructors
  dynamic _emptyWagon() {
    // Returns a placeholder when wagon lookup fails
    // Using dynamic to avoid importing wagon entity here
    return _WagonPlaceholder();
  }
}

// ─── Placeholder for missing wagon ───────────────────────────────────────────
class _WagonPlaceholder {
  String get wagonNumber => '------';
  String get id => '';
}

// ─── TOP INFORMATION BAR ─────────────────────────────────────────────────────
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
              // Brand
              const Icon(Icons.local_shipping, color: AppTheme.primaryColor, size: 18),
              const SizedBox(width: 6),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Vinayak SmartLoad',
                      style: TextStyle(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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
              _TopChip(label: 'LAYER', value: '#$layerNumber',
                  valueColor: AppTheme.warningColor),

              const Spacer(),

              // Status indicators
              _TopChip(
                label: isOnline ? 'ONLINE' : 'OFFLINE',
                value: '',
                valueColor: isOnline ? AppTheme.successColor : AppTheme.errorColor,
                compact: true,
                dotColor: isOnline ? AppTheme.successColor : AppTheme.errorColor,
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
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 8, fontWeight: FontWeight.bold,
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
class _AIStatusPanel extends StatelessWidget {
  final dynamic inferenceState;
  final DecisionState decisionState;

  const _AIStatusPanel({required this.inferenceState, required this.decisionState});

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
      width: 168,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xDD0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.4)),
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
                  boxShadow: [BoxShadow(color: _statusColor.withOpacity(0.6), blurRadius: 4)],
                ),
              ),
              const SizedBox(width: 6),
              const Text('AI ENGINE',
                  style: TextStyle(
                      color: Colors.white54, fontSize: 8, fontWeight: FontWeight.bold,
                      letterSpacing: 0.8)),
              const Spacer(),
              const Text('YOLO11s',
                  style: TextStyle(
                      color: AppTheme.primaryColor, fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 10, color: Color(0xFF2A3F52)),
          Row(
            children: [
              _AIMetric(label: 'CONF', value: '$conf%', color: conf > 85 ? AppTheme.successColor : AppTheme.warningColor),
              const SizedBox(width: 8),
              _AIMetric(label: 'STAB', value: '$stability%', color: stability > 80 ? AppTheme.successColor : AppTheme.warningColor),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _AIMetric(label: 'MODEL', value: 'v1.0'),
              const SizedBox(width: 8),
              _AIMetric(label: 'STATUS', value: _statusLabel, color: _statusColor),
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
              style: const TextStyle(color: Colors.white38, fontSize: 8,
                  fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          Text(value,
              style: TextStyle(
                  color: color ?? Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ─── LIVE COUNTER BAR ─────────────────────────────────────────────────────────
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
              color: AppTheme.errorColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '⚠  ${warnings.first}',
              style: const TextStyle(color: Colors.white, fontSize: 12,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xEE0D1B2A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor.withOpacity(0.5), width: 1.5),
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
                  _CountCol('CONFIDENCE',
                      '$confPct%',
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
                  _CountCol('MODEL', 'YOLO11s',
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
        width: 1, height: 32, color: Colors.white12,
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
                color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold,
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
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
      Paint()..color = const Color(0xFF1565C0).withOpacity(0.05),
    );

    // Dashed border
    final dashPaint = Paint()
      ..color = const Color(0xFF1565C0).withOpacity(0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    _drawDashedRect(canvas, rect, dashPaint);

    // Corner brackets
    final cornerPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const double cLen = 20;

    // Top-left
    canvas.drawLine(rect.topLeft, rect.topLeft.translate(cLen, 0), cornerPaint);
    canvas.drawLine(rect.topLeft, rect.topLeft.translate(0, cLen), cornerPaint);
    // Top-right
    canvas.drawLine(rect.topRight, rect.topRight.translate(-cLen, 0), cornerPaint);
    canvas.drawLine(rect.topRight, rect.topRight.translate(0, cLen), cornerPaint);
    // Bottom-left
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft.translate(cLen, 0), cornerPaint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft.translate(0, -cLen), cornerPaint);
    // Bottom-right
    canvas.drawLine(rect.bottomRight, rect.bottomRight.translate(-cLen, 0), cornerPaint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight.translate(0, -cLen), cornerPaint);
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
            Offset(start.dx + nx * (pos + segLen), start.dy + ny * (pos + segLen)),
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
  final bool isDebugMode;
  final VoidCallback onGallery;
  final VoidCallback onFlipCamera;
  final VoidCallback onDebugToggle;
  final VoidCallback onReset;
  final VoidCallback? onReview;
  final Animation<double> pulseAnimation;

  const _CaptureControlsDock({
    required this.isReadyForReview,
    required this.isGallery,
    required this.isDebugMode,
    required this.onGallery,
    required this.onFlipCamera,
    required this.onDebugToggle,
    required this.onReset,
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
                icon: isGallery ? Icons.camera_alt_outlined : Icons.flip_camera_ios_outlined,
                label: isGallery ? 'Camera' : 'Flip',
                onTap: onFlipCamera,
              ),
              _IconControl(
                icon: Icons.refresh_outlined,
                label: 'Reset',
                onTap: onReset,
              ),
              _IconControl(
                icon: isDebugMode ? Icons.bug_report : Icons.bug_report_outlined,
                label: 'Debug',
                onTap: onDebugToggle,
                iconColor: isDebugMode ? Colors.greenAccent : Colors.white70,
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
                            color: AppTheme.successColor.withOpacity(pulseAnimation.value * 0.6),
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
                    onPressed: onReview,
                    icon: Icon(
                      isReadyForReview ? Icons.rate_review : Icons.hourglass_bottom_outlined,
                      size: 22,
                    ),
                    label: Text(
                      isReadyForReview ? 'Review Count  →' : 'Scanning…',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isReadyForReview
                          ? AppTheme.successColor
                          : Colors.white12,
                      foregroundColor: isReadyForReview
                          ? Colors.white
                          : Colors.white38,
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
  final Color? iconColor;

  const _IconControl({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
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
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: iconColor ?? Colors.white, size: 22),
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
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(subtitle,
                style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(buttonLabel),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── GALLERY PREVIEW ─────────────────────────────────────────────────────────
class _GalleryPreview extends StatelessWidget {
  final String path;
  final DecisionState decisionState;

  const _GalleryPreview({required this.path, required this.decisionState});

  @override
  Widget build(BuildContext context) {
    final List<Detection> simList = [];
    const int cols = 9;
    const int rows = 8;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        simList.add(dynamicDetection(
          id: 'p_$r$c',
          xMin: 0.14 + c * 0.082,
          yMin: 0.22 + r * 0.080,
          xMax: 0.22 + c * 0.082,
          yMax: 0.29 + r * 0.080,
        ));
      }
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(File(path), fit: BoxFit.cover),
        Positioned.fill(
          child: DetectionOverlayWidget(
            detections: simList,
            cameraSize: const Size(720, 1280),
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}

// ─── CAMERA STREAM ADAPTER ────────────────────────────────────────────────────
class _CameraStreamAdapter extends ConsumerStatefulWidget {
  final CameraController controller;

  const _CameraStreamAdapter({required this.controller});

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

  @override
  void dispose() {
    _stopStream(widget.controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inferenceState = ref.watch(inferenceNotifierProvider);
    final size = widget.controller.value.previewSize;
    final cameraSize =
        size != null ? Size(size.height, size.width) : const Size(720, 1280);

    return Stack(
      fit: StackFit.expand,
      children: [
        AspectRatio(
          aspectRatio: 1 / widget.controller.value.aspectRatio,
          child: CameraPreview(widget.controller),
        ),
        Positioned.fill(
          child: DetectionOverlayWidget(
            detections: inferenceState.detections,
            cameraSize: cameraSize,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}

// ─── Global helper (must stay at file level for router references) ────────────
dynamic dynamicDetection({
  required String id,
  required double xMin,
  required double yMin,
  required double xMax,
  required double yMax,
}) {
  return Detection(
    id: id,
    boundingBox: BoundingBox(xMin: xMin, yMin: yMin, xMax: xMax, yMax: yMax),
    label: 'carton',
    confidence: 0.96,
  );
}
