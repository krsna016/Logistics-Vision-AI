import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;

import '../../../../theme/app_theme.dart';
import '../../../../presentation/widgets/app_card.dart';
import '../providers/layer_providers.dart';
import '../../domain/entities/ai_result.dart';
import '../../domain/entities/layer.dart';
import '../../../camera/presentation/widgets/detection_overlay_widget.dart';
import '../../../../utils/logger.dart';
import '../../../camera/domain/entities/detection.dart';

class LayerReviewScreen extends ConsumerStatefulWidget {
  final String truckId;
  final AIResult aiResult;
  final String? photoPath;
  final String? initialNotes;

  const LayerReviewScreen({
    super.key,
    required this.truckId,
    required this.aiResult,
    this.photoPath,
    this.initialNotes,
  });

  @override
  ConsumerState<LayerReviewScreen> createState() => _LayerReviewScreenState();
}

class _LayerReviewScreenState extends ConsumerState<LayerReviewScreen>
    with TickerProviderStateMixin {
  final _notesCtrl = TextEditingController();
  bool _isSaving = false;
  String? _errorMessage;
  late int _correctedCount;
  late List<Detection> _editableDetections;
  final Set<String> _hiddenDetectionIds = <String>{};
  final List<_ReviewSnapshot> _history = <_ReviewSnapshot>[];

  @override
  void initState() {
    super.initState();
    _notesCtrl.text = widget.initialNotes ?? '';
    _correctedCount = widget.aiResult.count;
    _editableDetections = List<Detection>.of(widget.aiResult.detections);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _adjustCount(int delta) {
    setState(() {
      _saveSnapshot();
      _animateCountTo((_correctedCount + delta).clamp(0, 9999));
    });
  }

  void _saveSnapshot() {
    _history.add(_ReviewSnapshot(
      hiddenIds: Set<String>.of(_hiddenDetectionIds),
      count: _correctedCount,
    ));
    if (_history.length > 20) _history.removeAt(0);
  }

  void _animateCountTo(int nextCount) {
    _correctedCount = nextCount;
  }

  List<Detection> get _visibleDetections => _editableDetections
      .where((detection) => !_hiddenDetectionIds.contains(detection.id))
      .toList(growable: false);

  void _toggleDetection(Detection detection) {
    setState(() {
      _saveSnapshot();
      if (_hiddenDetectionIds.contains(detection.id)) {
        _hiddenDetectionIds.remove(detection.id);
      } else {
        _hiddenDetectionIds.add(detection.id);
      }
      _animateCountTo(_visibleDetections.length);
    });
  }

  void _undoLastChange() {
    if (_history.isEmpty) return;
    setState(() {
      final snapshot = _history.removeLast();
      _hiddenDetectionIds
        ..clear()
        ..addAll(snapshot.hiddenIds);
      _animateCountTo(snapshot.count);
    });
  }

  void _resetReview() {
    setState(() {
      if (_hiddenDetectionIds.isNotEmpty ||
          _correctedCount != widget.aiResult.count) {
        _saveSnapshot();
      }
      _hiddenDetectionIds.clear();
      _animateCountTo(widget.aiResult.count);
    });
  }

  Future<void> _onSave() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final noteText = [
        if (widget.aiResult.modelVersion == 'MANUAL_COUNT')
          'Count method: Manual operator entry',
        if (_notesCtrl.text.isNotEmpty) _notesCtrl.text.trim(),
      ].join(' | ');

      final error =
          await ref.read(layerListProvider(widget.truckId).notifier).saveLayer(
                cartonCount: _correctedCount,
                defectCount: widget.aiResult.defectCount,
                confidence: widget.aiResult.averageConfidence,
                notes: noteText.isEmpty ? null : noteText,
                photoPath: widget.photoPath,
              );

      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = error;
        });

        if (error == null) {
          AppLogger.info('Layer saved: $_correctedCount cartons.');
          context.go('/trucks/${widget.truckId}');
        }
      }
    } catch (e, stack) {
      AppLogger.error('Inference Save Pipeline Exception', e, stack);
      setState(() {
        _isSaving = false;
        _errorMessage = 'Save failed. Database rolled back.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final layerState = ref.watch(layerListProvider(widget.truckId));
    final currentLayerNum = layerState.layers.length + 1;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Review Layer Scan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(
                'Layer #$currentLayerNum  •  Truck ${widget.truckId.substring(0, 6)}…',
                style: const TextStyle(
                    fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
        actions: const [],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _ImagePreviewSection(
            photoPath: widget.photoPath,
            detections: _visibleDetections,
            allDetections: _editableDetections,
            onDetectionTapped: _toggleDetection,
          ),
          if (_errorMessage != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 106,
              child: Material(
                color: AppTheme.errorColor,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(_errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),

          // ── Sticky Bottom Action Bar ────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _ReviewBottomBar(
              isSaving: _isSaving,
              correctedCount: _correctedCount,
              onIncrease: () => _adjustCount(1),
              onDecrease: () => _adjustCount(-1),
              onConfirm: _onSave,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-Widgets ─────────────────────────────────────────────────────────────

class _ImagePreviewSection extends StatefulWidget {
  final String? photoPath;
  final List<Detection> detections;
  final List<Detection> allDetections;
  final ValueChanged<Detection> onDetectionTapped;

  const _ImagePreviewSection({
    required this.photoPath,
    required this.detections,
    required this.allDetections,
    required this.onDetectionTapped,
  });

  @override
  State<_ImagePreviewSection> createState() => _ImagePreviewSectionState();
}

class _ImagePreviewSectionState extends State<_ImagePreviewSection> {
  late final TransformationController _zoomController;
  Size _photoSize = const Size(720, 1280);

  @override
  void initState() {
    super.initState();
    _zoomController = TransformationController();
    _loadPhotoSize();
  }

  Future<void> _loadPhotoSize() async {
    final path = widget.photoPath;
    if (path == null) return;
    try {
      final bytes = await File(path).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded != null && mounted) {
        setState(() => _photoSize = Size(
              decoded.width.toDouble(),
              decoded.height.toDouble(),
            ));
      }
    } catch (_) {
      // Keep the safe fallback size when the reference image cannot be read.
    }
  }

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        InteractiveViewer(
          transformationController: _zoomController,
          minScale: 1,
          maxScale: 4,
          boundaryMargin: const EdgeInsets.all(80),
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.photoPath != null
                  ? Image.file(File(widget.photoPath!), fit: BoxFit.contain)
                  : Container(
                      color: const Color(0xFF0A1628),
                      child: const Center(
                        child: Icon(Icons.photo_camera_outlined,
                            size: 80, color: Colors.white24),
                      ),
                    ),
              Positioned.fill(
                child: DetectionOverlayWidget(
                  detections: widget.detections,
                  hitTestDetections: widget.allDetections,
                  cameraSize: _photoSize,
                  fit: BoxFit.contain,
                  showLabels: false,
                  onDetectionTapped: widget.onDetectionTapped,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountSummaryCard extends StatelessWidget {
  final int aiCount;
  final int correctedCount;
  final double confidence;
  final int layerNumber;
  final Animation<int> countAnimation;
  final AnimationController countController;
  final bool isManual;

  const _CountSummaryCard({
    required this.aiCount,
    required this.correctedCount,
    required this.confidence,
    required this.layerNumber,
    required this.countAnimation,
    required this.countController,
    required this.isManual,
  });

  @override
  Widget build(BuildContext context) {
    final hasCorrection = !isManual && correctedCount != aiCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.15),
            AppTheme.primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Animated count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TOTAL CARTONS',
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
                const SizedBox(height: 4),
                AnimatedBuilder(
                  animation: countController,
                  builder: (ctx, _) => Text(
                    '${countAnimation.value}',
                    style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1),
                  ),
                ),
                if (hasCorrection)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'AI: $aiCount  →  Corrected: $correctedCount',
                      style: const TextStyle(
                          color: AppTheme.warningColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),

          // Right metrics
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatBadge('LAYER', '#$layerNumber', AppTheme.primaryColor),
              const SizedBox(height: 8),
              if (!isManual)
                _StatBadge('CONF', '$confidence%', AppTheme.successColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBadge(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _LayerHistoryCard extends StatelessWidget {
  final List<LayerRecord> layers;
  final int currentCount;
  final int currentLayerNum;

  const _LayerHistoryCard({
    required this.layers,
    required this.currentCount,
    required this.currentLayerNum,
  });

  @override
  Widget build(BuildContext context) {
    final layerList = layers;
    if (layerList.isEmpty) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_outlined,
                  size: 16, color: AppTheme.textSecondary),
              SizedBox(width: 8),
              Text('Layer History',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...List.generate(
                  layerList.length,
                  (i) {
                    final layer = layerList[i];
                    return _LayerHistoryChip(
                      label: 'L${layer.layerNumber}',
                      count: layer.cartonCount,
                      isCurrent: false,
                    );
                  },
                ),
                _LayerHistoryChip(
                  label: 'L$currentLayerNum',
                  count: currentCount,
                  isCurrent: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LayerHistoryChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isCurrent;

  const _LayerHistoryChip({
    required this.label,
    required this.count,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppTheme.primaryColor.withValues(alpha: 0.2)
            : AppTheme.cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isCurrent
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                  letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text('$count',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isCurrent ? Colors.white : AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _ManualCorrectionCard extends StatelessWidget {
  final int aiCount;
  final int correctedCount;
  final bool hasCorrection;
  final String? correctionReason;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final ValueChanged<String?> onReasonSelected;

  const _ManualCorrectionCard({
    required this.aiCount,
    required this.correctedCount,
    required this.hasCorrection,
    required this.correctionReason,
    required this.isExpanded,
    required this.onToggle,
    required this.onIncrease,
    required this.onDecrease,
    required this.onReasonSelected,
  });

  static const _reasons = [
    'Hidden carton',
    'Poor lighting',
    'AI miss',
    'Damaged carton',
    'Double count',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header toggle
          GestureDetector(
            onTap: onToggle,
            child: Row(
              children: [
                const Icon(Icons.tune_outlined,
                    size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                const Text('Manual Correction',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                if (hasCorrection)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'AI: $aiCount → $correctedCount',
                      style: const TextStyle(
                          color: AppTheme.warningColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),

          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(height: 20, color: AppTheme.dividerColor),

                // Count controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CounterButton(
                      icon: Icons.remove,
                      onTap: onDecrease,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(width: 24),
                    Text(
                      '$correctedCount',
                      style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 24),
                    _CounterButton(
                      icon: Icons.add,
                      onTap: onIncrease,
                      color: AppTheme.successColor,
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Text(
                  'Correction Reason',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _reasons.map((reason) {
                    final selected = correctionReason == reason;
                    return GestureDetector(
                      onTap: () => onReasonSelected(selected ? null : reason),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.warningColor.withValues(alpha: 0.2)
                              : AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          reason,
                          style: TextStyle(
                              color: selected
                                  ? AppTheme.warningColor
                                  : AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _CounterButton(
      {required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

class _ReviewSnapshot {
  final Set<String> hiddenIds;
  final int count;

  const _ReviewSnapshot({required this.hiddenIds, required this.count});
}

class _ReviewBottomBar extends StatelessWidget {
  final bool isSaving;
  final int correctedCount;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onConfirm;

  const _ReviewBottomBar({
    required this.isSaving,
    required this.correctedCount,
    required this.onIncrease,
    required this.onDecrease,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: const Border(top: BorderSide(color: AppTheme.dividerColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CounterButton(
                    icon: Icons.remove,
                    onTap: isSaving ? () {} : onDecrease,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$correctedCount',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 8),
                  _CounterButton(
                    icon: Icons.add,
                    onTap: isSaving ? () {} : onIncrease,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : onConfirm,
                icon: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check, size: 24),
                label: Text(isSaving ? 'Saving…' : 'Confirm'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
