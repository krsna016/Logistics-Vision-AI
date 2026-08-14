import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../../../theme/app_theme.dart';
import '../../../../utils/logger.dart';
import '../../../camera/presentation/widgets/detection_overlay_widget.dart';
import '../../../camera/domain/entities/detection.dart';
import '../../../layer/domain/entities/layer.dart';

/// Vertical timeline showing layer capture history.
class LayerTimeline extends StatelessWidget {
  final List<LayerRecord> layers;
  final bool isReadOnly;
  final void Function(LayerRecord layer) onEditNotes;
  final void Function(LayerRecord layer) onDeleteLayer;
  final Future<String?> Function(LayerRecord layer, List<Detection> detections)?
      onSaveDetections;

  const LayerTimeline({
    super.key,
    required this.layers,
    required this.isReadOnly,
    required this.onEditNotes,
    required this.onDeleteLayer,
    this.onSaveDetections,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: layers.length,
      itemBuilder: (context, index) {
        final layer = layers[index];
        final isLast = index == layers.length - 1;
        return _TimelineItem(
          layer: layer,
          isLast: isLast,
          isReadOnly: isReadOnly,
          onEditNotes: () => onEditNotes(layer),
          onDelete: () => onDeleteLayer(layer),
          onSaveDetections: onSaveDetections,
        );
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final LayerRecord layer;
  final bool isLast;
  final bool isReadOnly;
  final VoidCallback onEditNotes;
  final VoidCallback onDelete;
  final Future<String?> Function(LayerRecord layer, List<Detection> detections)?
      onSaveDetections;

  const _TimelineItem({
    required this.layer,
    required this.isLast,
    required this.isReadOnly,
    required this.onEditNotes,
    required this.onDelete,
    this.onSaveDetections,
  });

  bool get _hasDefects =>
      layer.defectCount > 0 ||
      (layer.notes != null && layer.notes!.toLowerCase().contains('defect'));
  Color get _statusColor =>
      _hasDefects ? AppTheme.warningColor : AppTheme.successColor;
  IconData get _statusIcon =>
      _hasDefects ? Icons.warning_amber_rounded : Icons.check_circle_rounded;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline left rail
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${layer.layerNumber}',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppTheme.dividerColor,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),

          // Content card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 7),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: isReadOnly ? null : onEditNotes,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Keep the full layer summary and its actions on one
                        // compact line. The card itself remains tappable for
                        // corrections, so a separate edit button is not needed.
                        Row(
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Layer ${layer.layerNumber}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    _CompactHeaderChip(
                                      icon: Icons.inventory_2_outlined,
                                      label: '${layer.cartonCount} Cartons',
                                      color: AppTheme.primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    _CompactHeaderChip(
                                      icon: Icons.access_time_outlined,
                                      label: _formatTime(layer.timestamp),
                                      color: AppTheme.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            if (!isReadOnly)
                              IconButton(
                                onPressed: onDelete,
                                tooltip: 'Delete layer',
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints.tightFor(
                                  width: 23,
                                  height: 25,
                                ),
                                icon: const Icon(Icons.delete_outline,
                                    size: 16, color: AppTheme.errorColor),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: _statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_statusIcon,
                                      size: 11, color: _statusColor),
                                  const SizedBox(width: 2),
                                  Text(_hasDefects ? 'Defect' : 'OK',
                                      style: TextStyle(
                                          color: _statusColor,
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),

                        // Keep every item readable on mixed-item layers. Each
                        // allocation wraps independently instead of forcing the
                        // entire breakdown into one horizontal label.
                        if (layer.itemAllocations.isNotEmpty ||
                            layer.defectCount > 0) ...[
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: [
                              for (final allocation in layer.itemAllocations)
                                _ChipLabel(
                                  icon: Icons.category_outlined,
                                  label:
                                      '${allocation.itemName}: ${allocation.quantity}',
                                  color: AppTheme.successColor,
                                  flexibleLabel: true,
                                ),
                              if (layer.defectCount > 0)
                                _ChipLabel(
                                  icon: Icons.warning_amber_outlined,
                                  label: '${layer.defectCount} Defective',
                                  color: AppTheme.warningColor,
                                ),
                            ],
                          ),
                        ],

                        if (layer.photoPath != null) ...[
                          const SizedBox(height: 7),
                          _LayerPhotoThumbnail(
                            layer: layer,
                            canEdit: !isReadOnly && onSaveDetections != null,
                            onSaveDetections: onSaveDetections,
                          ),
                        ],

                        if (layer.notes != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.warningColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.note_outlined,
                                    size: 12, color: AppTheme.warningColor),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    layer.notes!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.warningColor,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _LayerPhotoThumbnail extends StatelessWidget {
  final LayerRecord layer;
  final bool canEdit;
  final Future<String?> Function(LayerRecord layer, List<Detection> detections)?
      onSaveDetections;

  const _LayerPhotoThumbnail({
    required this.layer,
    required this.canEdit,
    this.onSaveDetections,
  });

  String get path => layer.photoPath!;

  Future<void> _openPhoto(BuildContext context) async {
    File? file;
    for (final candidate in [layer.croppedPhotoPath, layer.photoPath]) {
      if (candidate == null) continue;
      final possibleFile = File(candidate);
      if (await possibleFile.exists()) {
        file = possibleFile;
        break;
      }
    }
    if (file == null || !context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => LayerHistoryPhotoViewer(
        layer: layer,
        file: file!,
        canEdit: canEdit,
        onSaveDetections: onSaveDetections,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!File(path).existsSync()) return const SizedBox.shrink();
    return InkWell(
      onTap: () => _openPhoto(context),
      borderRadius: BorderRadius.circular(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            SizedBox(
              height: 68,
              width: double.infinity,
              child: Image(
                image: ResizeImage(
                  FileImage(File(path)),
                  width: 1080,
                  height: 240,
                  policy: ResizeImagePolicy.fit,
                ),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              color: Colors.black54,
              child: const Row(
                children: [
                  Icon(Icons.photo_outlined, size: 15, color: Colors.white),
                  SizedBox(width: 6),
                  Text('Layer reference photo',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                  Spacer(),
                  Icon(Icons.open_in_full, size: 15, color: Colors.white70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LayerHistoryPhotoViewer extends StatefulWidget {
  final LayerRecord layer;
  final File file;
  final bool canEdit;
  final Future<String?> Function(LayerRecord layer, List<Detection> detections)?
      onSaveDetections;

  const LayerHistoryPhotoViewer({
    super.key,
    required this.layer,
    required this.file,
    required this.canEdit,
    this.onSaveDetections,
  });

  @override
  State<LayerHistoryPhotoViewer> createState() =>
      _LayerHistoryPhotoViewerState();
}

class _LayerHistoryPhotoViewerState extends State<LayerHistoryPhotoViewer> {
  Size _photoSize = const Size(720, 1280);
  bool _showMasks = false;
  bool _showNumbers = false;
  bool _isSaving = false;
  bool _saveLoopRunning = false;
  int _editRevision = 0;
  int _persistedRevision = 0;
  String? _errorMessage;
  late List<Detection> _detections;
  late int _displayCartonCount;
  final Set<String> _hiddenDetectionIds = <String>{};

  bool get _hasDetections => _detections.isNotEmpty;
  List<Detection> get _visibleDetections => _detections
      .where((detection) => !_hiddenDetectionIds.contains(detection.id))
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _detections = List<Detection>.of(widget.layer.detections);
    _displayCartonCount = _visibleDetections.length == _detections.length
        ? widget.layer.cartonCount
        : _visibleDetections.length;
    _showMasks = widget.canEdit && _detections.isNotEmpty;
    _loadPhotoSize();
  }

  void _addDetectionAt(Offset center) {
    final widths = _detections
        .map((item) => item.boundingBox.xMax - item.boundingBox.xMin)
        .where((value) => value > 0.01)
        .toList()
      ..sort();
    final heights = _detections
        .map((item) => item.boundingBox.yMax - item.boundingBox.yMin)
        .where((value) => value > 0.01)
        .toList()
      ..sort();
    final width = widths.isEmpty ? 0.12 : widths[widths.length ~/ 2];
    final height = heights.isEmpty ? 0.10 : heights[heights.length ~/ 2];
    final box = Rect.fromLTWH(
      (center.dx - width / 2).clamp(0.0, 1.0 - width),
      (center.dy - height / 2).clamp(0.0, 1.0 - height),
      width,
      height,
    );
    setState(() {
      _detections.add(Detection(
        id: 'history_manual_${DateTime.now().microsecondsSinceEpoch}',
        boundingBox: BoundingBox(
          xMin: box.left.clamp(0.0, 1.0),
          yMin: box.top.clamp(0.0, 1.0),
          xMax: box.right.clamp(0.0, 1.0),
          yMax: box.bottom.clamp(0.0, 1.0),
        ),
        label: 'carton',
        confidence: 1,
        color: const Color(0xFF34D399),
        metadata: const {'manuallyAdded': true, 'source': 'layerHistory'},
      ));
      _displayCartonCount = _visibleDetections.length;
      _showMasks = true;
      _errorMessage = null;
    });
    _queueAutoSave();
  }

  void _toggleDetection(Detection detection) {
    setState(() {
      if (_hiddenDetectionIds.contains(detection.id)) {
        _hiddenDetectionIds.remove(detection.id);
      } else {
        _hiddenDetectionIds.add(detection.id);
      }
      _displayCartonCount = _visibleDetections.length;
      _errorMessage = null;
    });
    _queueAutoSave();
  }

  void _queueAutoSave() {
    _editRevision++;
    if (!_saveLoopRunning) unawaited(_drainAutoSaveQueue());
  }

  Future<void> _drainAutoSaveQueue() async {
    final callback = widget.onSaveDetections;
    if (callback == null || _saveLoopRunning) return;
    _saveLoopRunning = true;
    if (mounted) {
      setState(() {
        _isSaving = true;
        _errorMessage = null;
      });
    }
    while (mounted && _persistedRevision < _editRevision) {
      final targetRevision = _editRevision;
      final snapshot = List<Detection>.of(_visibleDetections);
      String? error;
      try {
        error = await callback(widget.layer, snapshot);
      } catch (exception, stack) {
        AppLogger.error(
          'Failed to auto-save Layer History boxes',
          exception,
          stack,
        );
        error = 'Failed to save verified boxes.';
      }
      if (!mounted) return;
      if (error != null) {
        setState(() => _errorMessage = error);
        break;
      }
      _persistedRevision = targetRevision;
    }
    _saveLoopRunning = false;
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _loadPhotoSize() async {
    try {
      final decoded = img.decodeImage(await widget.file.readAsBytes());
      if (decoded == null || !mounted) return;
      final oriented = img.bakeOrientation(decoded);
      setState(() {
        _photoSize = Size(
          oriented.width.toDouble(),
          oriented.height.toDouble(),
        );
      });
    } catch (error, stack) {
      // The image widget will surface an unreadable file while the overlay
      // retains a safe aspect-ratio fallback.
      AppLogger.warning(
        'Could not read Layer History image dimensions',
        error,
        stack,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    return Dialog(
      backgroundColor: const Color(0xFF07111F),
      insetPadding: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: viewport.width.clamp(0.0, 920.0).toDouble(),
        height: (viewport.height * 0.9).clamp(360.0, 900.0).toDouble(),
        child: Column(
          children: [
            Container(
              key: const ValueKey('layer-photo-summary'),
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(8, 4, 2, 4),
              decoration: const BoxDecoration(
                color: AppTheme.cardColor,
                border: Border(
                  bottom: BorderSide(color: AppTheme.dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'L${widget.layer.layerNumber}',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      '$_displayCartonCount cartons'
                      '${widget.layer.defectCount > 0 ? ' • ${widget.layer.defectCount} defective' : ''}',
                      key: const ValueKey('layer-photo-carton-count'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (_isSaving)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: SizedBox.square(
                        key: ValueKey('layer-auto-saving'),
                        dimension: 13,
                        child: CircularProgressIndicator(strokeWidth: 1.8),
                      ),
                    ),
                  _CompactToggleButton(
                    key: const ValueKey('layer-mask-toggle'),
                    tooltip: _showMasks ? 'Hide masks' : 'Show masks',
                    icon: Icons.gesture_rounded,
                    selected: _showMasks,
                    enabled: _hasDetections,
                    onPressed: () => setState(() => _showMasks = !_showMasks),
                  ),
                  _CompactToggleButton(
                    key: const ValueKey('layer-number-toggle'),
                    tooltip: _showNumbers ? 'Hide numbers' : 'Show numbers',
                    icon: Icons.pin_outlined,
                    selected: _showNumbers,
                    enabled: _hasDetections,
                    onPressed: () =>
                        setState(() => _showNumbers = !_showNumbers),
                  ),
                  IconButton(
                    tooltip: 'Close image',
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: Colors.black,
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  boundaryMargin: const EdgeInsets.all(80),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: ResizeImage(
                          FileImage(widget.file),
                          width: 1920,
                          height: 1920,
                          policy: ResizeImagePolicy.fit,
                        ),
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                      ),
                      if (_showMasks || _showNumbers || widget.canEdit)
                        Positioned.fill(
                          child: DetectionOverlayWidget(
                            key: const ValueKey('layer-mask-overlay'),
                            detections: _visibleDetections,
                            hitTestDetections: _detections,
                            cameraSize: _photoSize,
                            fit: BoxFit.contain,
                            showLabels: false,
                            showNumbers: _showNumbers,
                            showOutlines: _showMasks,
                            onDetectionTapped:
                                widget.canEdit ? _toggleDetection : null,
                            onEmptyAreaTapped:
                                widget.canEdit ? _addDetectionAt : null,
                          ),
                        ),
                      if (_errorMessage != null)
                        Positioned(
                          left: 12,
                          right: 12,
                          top: 10,
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactToggleButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onPressed;

  const _CompactToggleButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tooltip,
        onPressed: enabled ? onPressed : null,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 34, height: 34),
        icon: Icon(
          icon,
          size: 18,
          color: !enabled
              ? Colors.white24
              : selected
                  ? AppTheme.primaryColor
                  : Colors.white70,
        ),
      );
}

class _ChipLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool flexibleLabel;

  const _ChipLabel({
    required this.icon,
    required this.label,
    required this.color,
    this.flexibleLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: flexibleLabel ? 190 : double.infinity,
            ),
            child: Text(
              label,
              maxLines: flexibleLabel ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactHeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CompactHeaderChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
