import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../layer/domain/entities/layer.dart';

/// Vertical timeline showing layer capture history.
class LayerTimeline extends StatelessWidget {
  final List<LayerRecord> layers;
  final bool isReadOnly;
  final void Function(LayerRecord layer) onEditNotes;
  final void Function(String layerId) onDeleteLayer;

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
          onDelete: () => onDeleteLayer(layer.id),
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

  bool get _hasDefects => layer.notes != null && layer.notes!.toLowerCase().contains('defect');
  Color get _statusColor => _hasDefects ? AppTheme.warningColor : AppTheme.successColor;
  IconData get _statusIcon => _hasDefects ? Icons.warning_amber_rounded : Icons.check_circle_rounded;
  String get _confidencePct => '${(layer.averageConfidence * 100).toStringAsFixed(0)}%';

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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.15),
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
          const SizedBox(width: 12),

          // Content card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hasDefects
                      ? AppTheme.warningColor.withOpacity(0.3)
                      : AppTheme.dividerColor,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: isReadOnly ? null : onEditNotes,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
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
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_statusIcon, size: 16, color: _statusColor),
                                const SizedBox(width: 4),
                                Text(
                                  _hasDefects ? 'Defect' : 'OK',
                                  style: TextStyle(
                                    color: _statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Stats row
                        Row(
                          children: [
                            _ChipLabel(
                              icon: Icons.inventory_2_outlined,
                              label: '${layer.cartonCount} Cartons',
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            _ChipLabel(
                              icon: Icons.analytics_outlined,
                              label: 'AI: $_confidencePct',
                              color: AppTheme.successColor,
                            ),
                            const SizedBox(width: 8),
                            _ChipLabel(
                              icon: Icons.access_time_outlined,
                              label: _formatTime(layer.timestamp),
                              color: AppTheme.textSecondary,
                            ),
                          ],
                        ),

                        if (layer.notes != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.warningColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.note_outlined, size: 12, color: AppTheme.warningColor),
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

                        // Operator row + actions
                        if (!isReadOnly) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Operator: ${layer.operatorId}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: onEditNotes,
                                    borderRadius: BorderRadius.circular(6),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.edit_note_outlined, size: 18, color: AppTheme.textSecondary),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: onDelete,
                                    borderRadius: BorderRadius.circular(6),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.delete_outline, size: 18, color: AppTheme.errorColor),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

class _ChipLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ChipLabel({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
