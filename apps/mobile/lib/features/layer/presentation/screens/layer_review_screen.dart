import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../truck/presentation/providers/truck_providers.dart';
import '../../../wagon/domain/entities/wagon.dart';
import '../../../wagon/presentation/providers/wagon_providers.dart';
import '../../../../core/presentation/widgets/unsaved_changes_guard.dart';
import '../../../../core/storage/image_storage_service.dart';

// Retained only for the legacy, non-rendered toolbar implementation below.
// The active review experience is now fully tap-driven.
enum _CorrectionMode { inspect, add, remove }

enum _OutlineColorMode { auto, dark, light }

class LayerReviewScreen extends ConsumerStatefulWidget {
  final String truckId;
  final AIResult aiResult;
  final String? photoPath;
  final String? auditPhotoPath;
  final CountingRegion? countingRegion;
  final String? initialNotes;
  final Future<AIResult> Function()? finalResultLoader;

  const LayerReviewScreen({
    super.key,
    required this.truckId,
    required this.aiResult,
    this.photoPath,
    this.auditPhotoPath,
    this.countingRegion,
    this.initialNotes,
    this.finalResultLoader,
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
  late int _correctedDefectCount;
  late List<Detection> _editableDetections;
  late AIResult _aiResult;
  bool _isFinalizing = false;
  bool _finalizationFailed = false;
  bool _showNumbers = true;
  _OutlineColorMode _outlineColorMode = _OutlineColorMode.auto;
  final Set<String> _hiddenDetectionIds = <String>{};
  final List<_ReviewSnapshot> _history = <_ReviewSnapshot>[];
  Map<String, int> _itemAllocations = {};

  @override
  void initState() {
    super.initState();
    _notesCtrl.text = widget.initialNotes ?? '';
    _notesCtrl.addListener(_handleNotesChanged);
    _aiResult = widget.aiResult;
    _correctedCount = _aiResult.count;
    _correctedDefectCount = _aiResult.defectCount;
    _editableDetections = List<Detection>.of(_aiResult.detections);
    final resultLoader = widget.finalResultLoader;
    if (resultLoader != null) {
      _isFinalizing = true;
      // Paint a responsive Review page before starting expensive image/model
      // work. The operator sees the photo and progress UI immediately.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _resolveFinalResult(resultLoader());
      });
    }
  }

  void _handleNotesChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _resolveFinalResult(Future<AIResult> pendingResult) async {
    try {
      final result = await pendingResult;
      if (!mounted) return;
      setState(() {
        _aiResult = result;
        _editableDetections = List<Detection>.of(result.detections);
        _hiddenDetectionIds.clear();
        _history.clear();
        _correctedCount = result.count;
        _correctedDefectCount = result.defectCount;
        _isFinalizing = false;
        _finalizationFailed = false;
      });
    } catch (error, stack) {
      AppLogger.error('Final layer analysis failed in review', error, stack);
      if (!mounted) return;
      setState(() {
        _isFinalizing = false;
        _finalizationFailed = true;
        _errorMessage =
            'Final AI verification failed. Retake this layer before saving.';
      });
    }
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

  void _adjustDefectCount(int delta) {
    setState(() {
      _correctedDefectCount =
          (_correctedDefectCount + delta).clamp(0, _correctedCount);
    });
  }

  void _setCartonCount(int value) {
    setState(() {
      _saveSnapshot();
      _animateCountTo(value.clamp(0, 9999));
      _correctedDefectCount = _correctedDefectCount.clamp(0, _correctedCount);
    });
  }

  void _setDefectCount(int value) {
    setState(() {
      _correctedDefectCount = value.clamp(0, _correctedCount);
    });
  }

  Future<void> _editItemBreakdown(
      Wagon wagon, Map<String, int> loadedByItem) async {
    final controllers = {
      for (final item in wagon.items)
        item.name: TextEditingController(
            text: (_itemAllocations[item.name] ?? 0) == 0
                ? ''
                : '${_itemAllocations[item.name]}'),
    };
    final result = await showModalBottomSheet<Map<String, int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final values = {
            for (final entry in controllers.entries)
              entry.key: int.tryParse(entry.value.text.trim()) ?? 0,
          };
          final allocated =
              values.values.fold<int>(0, (sum, quantity) => sum + quantity);
          final validStock = wagon.items.every((item) {
            final remaining = item.quantity - (loadedByItem[item.name] ?? 0);
            return (values[item.name] ?? 0) <= remaining;
          });
          final canApply = allocated == _correctedCount && validStock;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Layer Item Breakdown',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    'Assign all $_correctedCount camera-counted cartons to one or more items.',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ...wagon.items.map((item) {
                    final remaining =
                        item.quantity - (loadedByItem[item.name] ?? 0);
                    final entered = values[item.name] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextField(
                        controller: controllers[item.name],
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (_) => setSheetState(() {}),
                        decoration: InputDecoration(
                          labelText: item.name,
                          suffixText: '$remaining left',
                          errorText: entered > remaining
                              ? 'Only $remaining cartons available'
                              : null,
                        ),
                      ),
                    );
                  }),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (allocated == _correctedCount
                              ? AppTheme.successColor
                              : AppTheme.warningColor)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      allocated == _correctedCount
                          ? 'Assigned: $allocated / $_correctedCount cartons ✓'
                          : 'Assigned: $allocated / $_correctedCount cartons  •  ${(_correctedCount - allocated).abs()} ${allocated < _correctedCount ? 'still unassigned' : 'too many'}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: allocated == _correctedCount
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: canApply
                        ? () => Navigator.pop(sheetContext, {
                              for (final entry in values.entries)
                                if (entry.value > 0) entry.key: entry.value,
                            })
                        : null,
                    child: const Text('Apply Item Breakdown'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    for (final controller in controllers.values) {
      controller.dispose();
    }
    if (result != null && mounted) {
      setState(() => _itemAllocations = result);
    }
  }

  void _saveSnapshot() {
    _history.add(_ReviewSnapshot(
      hiddenIds: Set<String>.of(_hiddenDetectionIds),
      detections: List<Detection>.of(_editableDetections),
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

  void _removeDetection(Detection detection) {
    if (_hiddenDetectionIds.contains(detection.id)) return;
    setState(() {
      _saveSnapshot();
      _hiddenDetectionIds.add(detection.id);
      _animateCountTo(_visibleDetections.length);
    });
  }

  void _restoreDetection(Detection detection) {
    if (!_hiddenDetectionIds.contains(detection.id)) return;
    setState(() {
      _saveSnapshot();
      _hiddenDetectionIds.remove(detection.id);
      _animateCountTo(_visibleDetections.length);
    });
  }

  void _toggleDetection(Detection detection) {
    if (_hiddenDetectionIds.contains(detection.id)) {
      _restoreDetection(detection);
    } else {
      _removeDetection(detection);
    }
  }

  void _addDetectionAt(Offset center) {
    final visible = _visibleDetections;
    final widths = visible
        .map((detection) =>
            detection.boundingBox.xMax - detection.boundingBox.xMin)
        .where((width) => width > 0.01)
        .toList()
      ..sort();
    final heights = visible
        .map((detection) =>
            detection.boundingBox.yMax - detection.boundingBox.yMin)
        .where((height) => height > 0.01)
        .toList()
      ..sort();
    final width = widths.isEmpty ? 0.12 : widths[widths.length ~/ 2];
    final height = heights.isEmpty ? 0.10 : heights[heights.length ~/ 2];
    final left = (center.dx - width / 2).clamp(0.0, 1.0 - width);
    final top = (center.dy - height / 2).clamp(0.0, 1.0 - height);
    setState(() {
      _saveSnapshot();
      _editableDetections.add(
        Detection(
          id: 'manual_${DateTime.now().microsecondsSinceEpoch}',
          boundingBox: BoundingBox(
            xMin: left,
            yMin: top,
            xMax: left + width,
            yMax: top + height,
          ),
          label: 'carton',
          confidence: 1,
          color: const Color(0xFF34D399),
          metadata: const {'manuallyAdded': true},
        ),
      );
      _animateCountTo(_visibleDetections.length);
    });
  }

  // ignore: unused_element
  void _undoLastChange() {
    if (_history.isEmpty) return;
    setState(() {
      final snapshot = _history.removeLast();
      _editableDetections = List<Detection>.of(snapshot.detections);
      _hiddenDetectionIds
        ..clear()
        ..addAll(snapshot.hiddenIds);
      _animateCountTo(snapshot.count);
    });
  }

  // ignore: unused_element
  void _resetReview() {
    setState(() {
      if (_hiddenDetectionIds.isNotEmpty ||
          _editableDetections.length != _aiResult.detections.length ||
          _correctedCount != _aiResult.count) {
        _saveSnapshot();
      }
      _hiddenDetectionIds.clear();
      _editableDetections = List<Detection>.of(_aiResult.detections);
      _animateCountTo(_aiResult.count);
    });
  }

  Future<void> _onSave() async {
    if (_isSaving || _isFinalizing || _finalizationFailed) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final trucks = ref
          .read(truckListProvider)
          .trucks
          .where((entry) => entry.id == widget.truckId);
      final truck = trucks.isEmpty ? null : trucks.first;
      final wagons = truck?.wagonId == null
          ? const <Wagon>[]
          : ref
              .read(wagonListProvider)
              .wagons
              .where((entry) => entry.id == truck!.wagonId)
              .toList();
      final wagon = wagons.isEmpty ? null : wagons.first;
      if (wagon != null && wagon.items.isNotEmpty) {
        final allocated = _itemAllocations.values
            .fold<int>(0, (sum, quantity) => sum + quantity);
        if (allocated != _correctedCount) {
          setState(() {
            _isSaving = false;
            _errorMessage =
                'Assign all $_correctedCount cartons in the item breakdown.';
          });
          return;
        }
        final loaded = await ref.read(wagonInventoryProvider(wagon.id).future);
        for (final entry in _itemAllocations.entries) {
          final manifestItem =
              wagon.items.firstWhere((item) => item.name == entry.key);
          final remaining = manifestItem.quantity - (loaded[entry.key] ?? 0);
          if (entry.value > remaining) {
            setState(() {
              _isSaving = false;
              _errorMessage =
                  'Only $remaining cartons of ${entry.key} remain in the wagon.';
            });
            return;
          }
        }
      }
      final noteText = _notesCtrl.text.trim();

      final error =
          await ref.read(layerListProvider(widget.truckId).notifier).saveLayer(
                cartonCount: _correctedCount,
                defectCount: _correctedDefectCount,
                confidence: _aiResult.averageConfidence,
                notes: noteText.isEmpty ? null : noteText,
                itemAllocations: _itemAllocations.entries
                    .map((entry) => LayerItemAllocation(
                        itemName: entry.key, quantity: entry.value))
                    .toList(),
                photoPath: widget.auditPhotoPath ?? widget.photoPath,
                countingRegion: widget.countingRegion,
                croppedPhotoPath:
                    widget.countingRegion == null ? null : widget.photoPath,
              );

      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = error;
        });

        if (error == null) {
          AppLogger.info('Layer saved: $_correctedCount cartons.');
          // Return to the loading control center so the operator can select
          // the next wagon/truck without repeating the navigation flow.
          context.go('/wagons');
        }
      }
    } catch (e, stack) {
      AppLogger.error('Inference Save Pipeline Exception', e, stack);
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Save failed. Database rolled back.';
        });
      }
    }
  }

  Future<void> _discardUnsavedCapture() async {
    final storage = ImageStorageService();
    final paths = <String>{
      if (widget.photoPath != null) widget.photoPath!,
      if (widget.auditPhotoPath != null) widget.auditPhotoPath!,
    };
    for (final path in paths) {
      try {
        await storage.deleteImage(path);
      } catch (error, stack) {
        AppLogger.error('Could not remove discarded layer image', error, stack);
      }
    }
  }

  void _cycleOutlineColorMode() {
    setState(() {
      _outlineColorMode = switch (_outlineColorMode) {
        _OutlineColorMode.auto => _OutlineColorMode.dark,
        _OutlineColorMode.dark => _OutlineColorMode.light,
        _OutlineColorMode.light => _OutlineColorMode.auto,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final layerState = ref.watch(layerListProvider(widget.truckId));
    final matchingTrucks = ref
        .watch(truckListProvider)
        .trucks
        .where((entry) => entry.id == widget.truckId);
    final truck = matchingTrucks.isEmpty ? null : matchingTrucks.first;
    final matchingWagons = truck?.wagonId == null
        ? const <Wagon>[]
        : ref
            .watch(wagonListProvider)
            .wagons
            .where((entry) => entry.id == truck!.wagonId)
            .toList();
    final wagon = matchingWagons.isEmpty ? null : matchingWagons.first;
    final inventory =
        wagon == null ? null : ref.watch(wagonInventoryProvider(wagon.id));
    final currentLayerNum = layerState.layers.length + 1;
    // A review always represents a captured but not-yet-saved layer, even if
    // the operator has accepted every AI value without editing it.
    const hasUnsavedChanges = true;
    return UnsavedChangesGuard(
      hasUnsavedChanges: hasUnsavedChanges,
      isSaving: _isSaving || _isFinalizing,
      message: 'The reviewed carton count and layer details are not saved.',
      onDiscardConfirmed: _discardUnsavedCapture,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.surfaceColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.maybePop(context),
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
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            _ImagePreviewSection(
              photoPath: widget.photoPath,
              detections: _visibleDetections,
              allDetections: _editableDetections,
              showNumbers: _showNumbers,
              outlineColorMode: _outlineColorMode,
              onDetectionTapped: _toggleDetection,
              onEmptyAreaTapped: _addDetectionAt,
            ),
            Positioned(
              top: 14,
              left: 14,
              child: SafeArea(
                bottom: false,
                child: _OutlineColorButton(
                  mode: _outlineColorMode,
                  onPressed: _cycleOutlineColorMode,
                ),
              ),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: SafeArea(
                bottom: false,
                child: _ReviewOverlayButton(
                  tooltip: _showNumbers
                      ? 'Hide carton numbers'
                      : 'Show carton numbers',
                  icon: _showNumbers
                      ? Icons.pin_outlined
                      : Icons.format_list_numbered_rtl_rounded,
                  onPressed: () => setState(() => _showNumbers = !_showNumbers),
                ),
              ),
            ),
            if (_errorMessage != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 176,
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
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _ReviewBottomBar(
                isSaving: _isSaving,
                isFinalizing: _isFinalizing,
                finalizationFailed: _finalizationFailed,
                correctedCount: _correctedCount,
                defectCount: _correctedDefectCount,
                onIncrease: () => _adjustCount(1),
                onDecrease: () => _adjustCount(-1),
                onDefectIncrease: () => _adjustDefectCount(1),
                onDefectDecrease: () => _adjustDefectCount(-1),
                onCartonValueChanged: _setCartonCount,
                onDefectValueChanged: _setDefectCount,
                items: wagon?.items ?? const [],
                allocations: _itemAllocations,
                onEditItems: wagon == null
                    ? null
                    : () => _editItemBreakdown(
                        wagon, inventory?.valueOrNull ?? const {}),
                onConfirm: _onSave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-Widgets ─────────────────────────────────────────────────────────────

class _ImagePreviewSection extends StatefulWidget {
  final String? photoPath;
  final List<Detection> detections;
  final List<Detection> allDetections;
  final bool showNumbers;
  final _OutlineColorMode outlineColorMode;
  final ValueChanged<Detection> onDetectionTapped;
  final ValueChanged<Offset> onEmptyAreaTapped;

  const _ImagePreviewSection({
    required this.photoPath,
    required this.detections,
    required this.allDetections,
    required this.showNumbers,
    required this.outlineColorMode,
    required this.onDetectionTapped,
    required this.onEmptyAreaTapped,
  });

  @override
  State<_ImagePreviewSection> createState() => _ImagePreviewSectionState();
}

class _ImagePreviewSectionState extends State<_ImagePreviewSection> {
  late final TransformationController _zoomController;
  Size _photoSize = const Size(720, 1280);
  bool _useDarkPalette = false;

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
        final oriented = img.bakeOrientation(decoded);
        var luminanceTotal = 0.0;
        var samples = 0;
        final stepX = (oriented.width / 48).ceil().clamp(1, oriented.width);
        final stepY = (oriented.height / 48).ceil().clamp(1, oriented.height);
        for (var y = 0; y < oriented.height; y += stepY) {
          for (var x = 0; x < oriented.width; x += stepX) {
            final pixel = oriented.getPixel(x, y);
            luminanceTotal +=
                0.2126 * pixel.r + 0.7152 * pixel.g + 0.0722 * pixel.b;
            samples++;
          }
        }
        setState(() {
          _photoSize =
              Size(oriented.width.toDouble(), oriented.height.toDouble());
          _useDarkPalette = samples > 0 && luminanceTotal / samples >= 145;
        });
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
          panEnabled: true,
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
                  showNumbers: widget.showNumbers,
                  useDarkPalette: switch (widget.outlineColorMode) {
                    _OutlineColorMode.auto => _useDarkPalette,
                    _OutlineColorMode.dark => true,
                    _OutlineColorMode.light => false,
                  },
                  onDetectionTapped: widget.onDetectionTapped,
                  onEmptyAreaTapped: widget.onEmptyAreaTapped,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OutlineColorButton extends StatelessWidget {
  final _OutlineColorMode mode;
  final VoidCallback onPressed;

  const _OutlineColorButton({required this.mode, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (mode) {
      _OutlineColorMode.auto => (Icons.brightness_auto_rounded, 'Auto colours'),
      _OutlineColorMode.dark => (Icons.dark_mode_rounded, 'Dark colours'),
      _OutlineColorMode.light => (Icons.light_mode_rounded, 'Light colours'),
    };
    return _ReviewOverlayButton(
      tooltip: label,
      icon: icon,
      onPressed: onPressed,
    );
  }
}

class _ReviewOverlayButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _ReviewOverlayButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xE60A1722),
      shape: const CircleBorder(),
      elevation: 5,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 21,
        ),
        style: IconButton.styleFrom(
          fixedSize: const Size.square(44),
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}

// Legacy summary widget retained while the tap-driven review UI is active.
// ignore: unused_element
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

// Legacy history widget retained while the tap-driven review UI is active.
// ignore: unused_element
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

// Legacy correction widget retained while the tap-driven review UI is active.
// ignore: unused_element
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
  final List<Detection> detections;
  final int count;

  const _ReviewSnapshot({
    required this.hiddenIds,
    required this.detections,
    required this.count,
  });
}

// Legacy widget retained temporarily for source compatibility; it is not
// rendered by the tap-driven review screen.
// ignore: unused_element
class _CorrectionToolbar extends StatelessWidget {
  final _CorrectionMode mode;
  final int aiCount;
  final int finalCount;
  final int addedCount;
  final int removedCount;
  final bool canUndo;
  final bool enabled;
  final ValueChanged<_CorrectionMode> onModeChanged;
  final VoidCallback onUndo;
  final VoidCallback onReset;

  const _CorrectionToolbar({
    required this.mode,
    required this.aiCount,
    required this.finalCount,
    required this.addedCount,
    required this.removedCount,
    required this.canUndo,
    required this.enabled,
    required this.onModeChanged,
    required this.onUndo,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final instruction = switch (mode) {
      _CorrectionMode.inspect => 'Pinch to zoom and inspect every carton',
      _CorrectionMode.add => 'Drag a box around each missing carton',
      _CorrectionMode.remove => 'Tap an incorrect carton outline to remove it',
    };
    return Material(
      elevation: 8,
      color: const Color(0xF20D1B2A),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'AI $aiCount  •  +$addedCount  −$removedCount  •  Final $finalCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Undo correction',
                  onPressed: enabled && canUndo ? onUndo : null,
                  icon: const Icon(Icons.undo_rounded, size: 20),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Reset AI result',
                  onPressed: enabled ? onReset : null,
                  icon: const Icon(Icons.restart_alt_rounded, size: 20),
                ),
              ],
            ),
            Row(
              children: [
                _ModeButton(
                  label: 'Inspect',
                  icon: Icons.zoom_in_rounded,
                  selected: mode == _CorrectionMode.inspect,
                  enabled: enabled,
                  onTap: () => onModeChanged(_CorrectionMode.inspect),
                ),
                const SizedBox(width: 6),
                _ModeButton(
                  label: 'Add',
                  icon: Icons.add_box_outlined,
                  selected: mode == _CorrectionMode.add,
                  enabled: enabled,
                  onTap: () => onModeChanged(_CorrectionMode.add),
                ),
                const SizedBox(width: 6),
                _ModeButton(
                  label: 'Remove',
                  icon: Icons.indeterminate_check_box_outlined,
                  selected: mode == _CorrectionMode.remove,
                  enabled: enabled,
                  onTap: () => onModeChanged(_CorrectionMode.remove),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              instruction,
              style: const TextStyle(color: Colors.white60, fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected
            ? AppTheme.primaryColor.withValues(alpha: 0.28)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 16,
                    color: selected ? AppTheme.primaryColor : Colors.white70),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewBottomBar extends StatelessWidget {
  final bool isSaving;
  final bool isFinalizing;
  final bool finalizationFailed;
  final int correctedCount;
  final int defectCount;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onDefectIncrease;
  final VoidCallback onDefectDecrease;
  final ValueChanged<int> onCartonValueChanged;
  final ValueChanged<int> onDefectValueChanged;
  final VoidCallback onConfirm;
  final List<WagonItem> items;
  final Map<String, int> allocations;
  final VoidCallback? onEditItems;

  const _ReviewBottomBar({
    required this.isSaving,
    required this.isFinalizing,
    required this.finalizationFailed,
    required this.correctedCount,
    required this.defectCount,
    required this.onIncrease,
    required this.onDecrease,
    required this.onDefectIncrease,
    required this.onDefectDecrease,
    required this.onCartonValueChanged,
    required this.onDefectValueChanged,
    required this.onConfirm,
    required this.items,
    required this.allocations,
    required this.onEditItems,
  });

  @override
  Widget build(BuildContext context) {
    final isBusy = isSaving || isFinalizing || finalizationFailed;
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (items.isNotEmpty) ...[
            OutlinedButton.icon(
              onPressed: isBusy ? null : onEditItems,
              icon: const Icon(Icons.playlist_add_outlined),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  allocations.isEmpty
                      ? 'Set item breakdown *'
                      : allocations.entries
                          .map((entry) => '${entry.key}: ${entry.value}')
                          .join('  •  '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                side: BorderSide(
                  color: allocations.values.fold<int>(
                              0, (sum, quantity) => sum + quantity) ==
                          correctedCount
                      ? AppTheme.successColor
                      : AppTheme.warningColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _BottomCounter(
                  value: correctedCount,
                  label: 'Cartons',
                  color: AppTheme.primaryColor,
                  onDecrease: isBusy ? () {} : onDecrease,
                  onIncrease: isBusy ? () {} : onIncrease,
                  onValueChanged: isBusy ? (_) {} : onCartonValueChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: _BottomCounter(
                  value: defectCount,
                  label: 'Defects',
                  color: AppTheme.warningColor,
                  onDecrease: isBusy ? () {} : onDefectDecrease,
                  onIncrease: isBusy ? () {} : onDefectIncrease,
                  onValueChanged: isBusy ? (_) {} : onDefectValueChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: isBusy ? null : onConfirm,
                    icon: isBusy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check, size: 24),
                    label: Text(isSaving
                        ? 'Saving…'
                        : finalizationFailed
                            ? 'Retake required'
                            : isFinalizing
                                ? 'Analyzing…'
                                : 'Confirm'),
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
        ],
      ),
    );
  }
}

class _BottomCounter extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final ValueChanged<int> onValueChanged;

  const _BottomCounter({
    required this.value,
    required this.label,
    required this.color,
    required this.onDecrease,
    required this.onIncrease,
    required this.onValueChanged,
  });

  Future<void> _showNumberEditor(BuildContext context) async {
    final controller = TextEditingController(text: '$value')
      ..selection = TextSelection(baseOffset: 0, extentOffset: '$value'.length);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter $label count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: color.withValues(alpha: 0.10),
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: color),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: color, width: 2),
                ),
              ),
              onChanged: (text) {
                final parsed = int.tryParse(text);
                if (parsed != null) onValueChanged(parsed);
              },
              onSubmitted: (_) => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _CompactCounterButton(
            icon: Icons.remove_rounded,
            tooltip: 'Decrease $label',
            onTap: onDecrease,
          ),
          Expanded(
            child: Semantics(
              button: true,
              label: '$label count $value. Tap to enter an exact value.',
              child: InkWell(
                onTap: () => _showNumberEditor(context),
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$value',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                height: 1,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(width: 3),
                        const Icon(Icons.edit_rounded,
                            color: Colors.white70, size: 11),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(label,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            height: 1,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
          _CompactCounterButton(
            icon: Icons.add_rounded,
            tooltip: 'Increase $label',
            onTap: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _CompactCounterButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _CompactCounterButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: InkResponse(
          onTap: onTap,
          radius: 24,
          child: Container(
            width: 38,
            height: 42,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.24),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white70, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 25),
          ),
        ),
      ),
    );
  }
}
