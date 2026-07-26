import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../../../presentation/widgets/app_card.dart';
import '../providers/layer_providers.dart';
import '../../domain/entities/ai_result.dart';
import '../../../camera/presentation/widgets/detection_overlay_widget.dart';
import '../../../../utils/logger.dart';

class LayerReviewScreen extends ConsumerStatefulWidget {
  final String truckId;
  final AIResult aiResult;
  final String? photoPath;

  const LayerReviewScreen({
    super.key,
    required this.truckId,
    required this.aiResult,
    this.photoPath,
  });

  @override
  ConsumerState<LayerReviewScreen> createState() => _LayerReviewScreenState();
}

class _LayerReviewScreenState extends ConsumerState<LayerReviewScreen>
    with TickerProviderStateMixin {
  final _notesCtrl = TextEditingController();
  bool _isSaving = false;
  bool _showBoxes = true;
  bool _showManualCorrection = false;
  String? _errorMessage;
  late int _correctedCount;
  String? _correctionReason;

  late AnimationController _successController;
  late AnimationController _countController;
  late Animation<double> _successScale;
  late Animation<int> _countAnim;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _correctedCount = widget.aiResult.count;

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );

    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _countAnim = IntTween(begin: 0, end: _correctedCount).animate(
      CurvedAnimation(parent: _countController, curve: Curves.easeOut),
    );
    _countController.forward();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _successController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _adjustCount(int delta) {
    setState(() {
      _correctedCount = (_correctedCount + delta).clamp(0, 9999);
      _countAnim = IntTween(begin: _correctedCount - delta, end: _correctedCount)
          .animate(CurvedAnimation(parent: _countController, curve: Curves.easeOut));
      _countController.reset();
      _countController.forward();
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
        if (_notesCtrl.text.isNotEmpty) _notesCtrl.text.trim(),
        if (_correctionReason != null) 'Correction: $_correctionReason',
      ].join(' | ');

      final error = await ref.read(layerListProvider(widget.truckId).notifier).saveLayer(
            cartonCount: _correctedCount,
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
          setState(() => _showSuccess = true);
          _successController.forward();

          await Future.delayed(const Duration(milliseconds: 1800));
          if (mounted) context.go('/trucks/${widget.truckId}');
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
    final confPct = (widget.aiResult.averageConfidence * 100).toStringAsFixed(0);
    final aiCount = widget.aiResult.count;
    final hasCorrection = _correctedCount != aiCount;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/trucks/${widget.truckId}/camera'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Review Layer Scan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Layer #$currentLayerNum  •  Truck ${widget.truckId.substring(0, 6)}…',
                style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 16),
            label: const Text('Retake', style: TextStyle(color: Colors.white)),
            onPressed: () => context.go('/trucks/${widget.truckId}/camera'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. Image with bounding boxes ──────────────────────────
                _ImagePreviewSection(
                  photoPath: widget.photoPath,
                  aiResult: widget.aiResult,
                  showBoxes: _showBoxes,
                  onToggleBoxes: () => setState(() => _showBoxes = !_showBoxes),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── 2. Count Summary ─────────────────────────────────
                      _CountSummaryCard(
                        aiCount: aiCount,
                        correctedCount: _correctedCount,
                        confidence: double.parse(confPct),
                        layerNumber: currentLayerNum,
                        countAnimation: _countAnim,
                        countController: _countController,
                      ),
                      const SizedBox(height: 12),

                      // ── 3. Layer History ──────────────────────────────────
                      _LayerHistoryCard(
                        layers: layerState.layers,
                        currentCount: _correctedCount,
                        currentLayerNum: currentLayerNum,
                      ),
                      const SizedBox(height: 12),

                      // ── 4. Manual Correction ──────────────────────────────
                      _ManualCorrectionCard(
                        aiCount: aiCount,
                        correctedCount: _correctedCount,
                        hasCorrection: hasCorrection,
                        correctionReason: _correctionReason,
                        isExpanded: _showManualCorrection,
                        onToggle: () => setState(
                          () => _showManualCorrection = !_showManualCorrection,
                        ),
                        onIncrease: () => _adjustCount(1),
                        onDecrease: () => _adjustCount(-1),
                        onReasonSelected: (r) =>
                            setState(() => _correctionReason = r),
                      ),
                      const SizedBox(height: 12),

                      // ── 5. Notes ──────────────────────────────────────────
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.note_alt_outlined,
                                    size: 16, color: AppTheme.textSecondary),
                                SizedBox(width: 8),
                                Text('Verification Notes',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _notesCtrl,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                hintText:
                                    'Anomalies, stacking patterns, damage context…',
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.errorColor.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppTheme.errorColor, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(_errorMessage!,
                                    style: const TextStyle(
                                        color: AppTheme.errorColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
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
              onConfirm: _onSave,
              onRetake: () => context.go('/trucks/${widget.truckId}/camera'),
              onViewTruck: () => context.go('/trucks/${widget.truckId}'),
            ),
          ),

          // ── Success Overlay ─────────────────────────────────────────────
          if (_showSuccess)
            Positioned.fill(
              child: _SuccessOverlay(
                scaleAnimation: _successScale,
                cartonCount: _correctedCount,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Sub-Widgets ─────────────────────────────────────────────────────────────

class _ImagePreviewSection extends StatelessWidget {
  final String? photoPath;
  final AIResult aiResult;
  final bool showBoxes;
  final VoidCallback onToggleBoxes;

  const _ImagePreviewSection({
    required this.photoPath,
    required this.aiResult,
    required this.showBoxes,
    required this.onToggleBoxes,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.42;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base image
          photoPath != null
              ? Image.file(File(photoPath!), fit: BoxFit.cover)
              : Container(
                  color: const Color(0xFF0A1628),
                  child: const Center(
                    child: Icon(Icons.photo_camera_outlined,
                        size: 80, color: Colors.white24),
                  ),
                ),

          // Bounding boxes
          if (showBoxes)
            AnimatedOpacity(
              opacity: showBoxes ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Positioned.fill(
                child: DetectionOverlayWidget(
                  detections: aiResult.detections,
                  cameraSize: aiResult.frameSize,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Top gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 60,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Bottom gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0xFF121212)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Toggle bounding boxes
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: onToggleBoxes,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      showBoxes
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      showBoxes ? 'Hide Boxes' : 'Show Boxes',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom count badge
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${aiResult.count} cartons detected',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
          ),
        ],
      ),
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

  const _CountSummaryCard({
    required this.aiCount,
    required this.correctedCount,
    required this.confidence,
    required this.layerNumber,
    required this.countAnimation,
    required this.countController,
  });

  @override
  Widget build(BuildContext context) {
    final hasCorrection = correctedCount != aiCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.15),
            AppTheme.primaryColor.withOpacity(0.05),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.warningColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      'AI: $aiCount  →  Corrected: $correctedCount',
                      style: const TextStyle(
                          color: AppTheme.warningColor, fontSize: 11,
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
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
  final dynamic layers;
  final int currentCount;
  final int currentLayerNum;

  const _LayerHistoryCard({
    required this.layers,
    required this.currentCount,
    required this.currentLayerNum,
  });

  @override
  Widget build(BuildContext context) {
    final layerList = layers as List;
    if (layerList.isEmpty) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_outlined, size: 16, color: AppTheme.textSecondary),
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
            ? AppTheme.primaryColor.withOpacity(0.2)
            : AppTheme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isCurrent
                ? AppTheme.primaryColor.withOpacity(0.6)
                : AppTheme.dividerColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isCurrent ? AppTheme.primaryColor : AppTheme.textSecondary,
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
                const Icon(Icons.tune_outlined, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                const Text('Manual Correction',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                if (hasCorrection)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.15),
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
                          fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white),
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
                              ? AppTheme.warningColor.withOpacity(0.2)
                              : AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: selected
                                  ? AppTheme.warningColor
                                  : AppTheme.dividerColor),
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

  const _CounterButton({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

class _ReviewBottomBar extends StatelessWidget {
  final bool isSaving;
  final int correctedCount;
  final VoidCallback onConfirm;
  final VoidCallback onRetake;
  final VoidCallback onViewTruck;

  const _ReviewBottomBar({
    required this.isSaving,
    required this.correctedCount,
    required this.onConfirm,
    required this.onRetake,
    required this.onViewTruck,
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
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Secondary: Retake
          SizedBox(
            width: 56,
            height: 56,
            child: OutlinedButton(
              onPressed: onRetake,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: AppTheme.dividerColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: EdgeInsets.zero,
              ),
              child: const Icon(Icons.camera_alt_outlined, size: 20),
            ),
          ),
          const SizedBox(width: 10),

          // Secondary: View Truck
          SizedBox(
            width: 56,
            height: 56,
            child: OutlinedButton(
              onPressed: onViewTruck,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: AppTheme.dividerColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: EdgeInsets.zero,
              ),
              child: const Icon(Icons.local_shipping_outlined, size: 20),
            ),
          ),
          const SizedBox(width: 10),

          // Primary: Confirm
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : onConfirm,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle_outline, size: 22),
                label: Text(
                  isSaving
                      ? 'Saving…'
                      : 'Confirm  $correctedCount Cartons',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessOverlay extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final int cartonCount;

  const _SuccessOverlay({
    required this.scaleAnimation,
    required this.cartonCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
            margin: const EdgeInsets.all(40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B2A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: AppTheme.successColor.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.successColor.withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.successColor, width: 2),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: AppTheme.successColor, size: 44),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Layer Saved',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '$cartonCount Cartons Added',
                  style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Truck Total Updated  •  Continue to Next Layer',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
