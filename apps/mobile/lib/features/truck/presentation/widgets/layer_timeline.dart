import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../layer/domain/entities/layer.dart';

/// Vertical timeline showing layer capture history.
class LayerTimeline extends StatelessWidget {
  final List<LayerRecord> layers;
  final bool isReadOnly;
  final void Function(LayerRecord layer) onEditNotes;
  final void Function(LayerRecord layer) onDeleteLayer;

  const LayerTimeline({
    super.key,
    required this.layers,
    required this.isReadOnly,
    required this.onEditNotes,
    required this.onDeleteLayer,
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

  const _TimelineItem({
    required this.layer,
    required this.isLast,
    required this.isReadOnly,
    required this.onEditNotes,
    required this.onDelete,
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
                        // Header row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Layer ${layer.layerNumber}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isReadOnly) ...[
                                  IconButton(
                                    onPressed: onEditNotes,
                                    tooltip: 'Edit layer notes',
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                        minWidth: 27, minHeight: 27),
                                    icon: const Icon(Icons.edit_note_outlined,
                                        size: 17,
                                        color: AppTheme.textSecondary),
                                  ),
                                  IconButton(
                                    onPressed: onDelete,
                                    tooltip: 'Delete layer',
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                        minWidth: 27, minHeight: 27),
                                    icon: const Icon(Icons.delete_outline,
                                        size: 17, color: AppTheme.errorColor),
                                  ),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(_statusIcon,
                                          size: 12, color: _statusColor),
                                      const SizedBox(width: 3),
                                      Text(_hasDefects ? 'Defect' : 'OK',
                                          style: TextStyle(
                                              color: _statusColor,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),

                        // Stats row
                        Row(
                          children: [
                            if (layer.itemName != null &&
                                layer.itemName!.trim().isNotEmpty) ...[
                              _ChipLabel(
                                icon: Icons.category_outlined,
                                label: layer.itemName!,
                                color: AppTheme.successColor,
                              ),
                              const SizedBox(width: 6),
                            ],
                            _ChipLabel(
                              icon: Icons.inventory_2_outlined,
                              label: '${layer.cartonCount} Cartons',
                              color: AppTheme.primaryColor,
                            ),
                            if (layer.defectCount > 0) ...[
                              const SizedBox(width: 6),
                              _ChipLabel(
                                icon: Icons.warning_amber_outlined,
                                label: '${layer.defectCount} Defective',
                                color: AppTheme.warningColor,
                              ),
                            ],
                            const SizedBox(width: 6),
                            _ChipLabel(
                              icon: Icons.access_time_outlined,
                              label: _formatTime(layer.timestamp),
                              color: AppTheme.textSecondary,
                            ),
                          ],
                        ),

                        if (layer.photoPath != null) ...[
                          const SizedBox(height: 7),
                          _LayerPhotoThumbnail(path: layer.photoPath!),
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
  final String path;

  const _LayerPhotoThumbnail({required this.path});

  Future<void> _openPhoto(BuildContext context) async {
    final file = File(path);
    if (!await file.exists() || !context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: Image.file(file, fit: BoxFit.contain),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: File(path).exists(),
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
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
                  child: Image.file(File(path), fit: BoxFit.cover),
                ),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
      },
    );
  }
}

class _ChipLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ChipLabel(
      {required this.icon, required this.label, required this.color});

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
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
