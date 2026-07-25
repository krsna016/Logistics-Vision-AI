import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../core/audit/domain/entities/audit_event.dart';

class TimelineWidget extends StatelessWidget {
  final List<AuditEvent> events;
  final bool shrinkWrap;

  const TimelineWidget({
    super.key,
    required this.events,
    this.shrinkWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: const Text(
          'No activity events recorded yet.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isLast = index == events.length - 1;
        return _TimelineTile(event: event, isLast: isLast);
      },
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final AuditEvent event;
  final bool isLast;

  const _TimelineTile({required this.event, required this.isLast});

  IconData get _icon {
    final act = event.action.toLowerCase();
    if (act.contains('created') || act.contains('added')) return Icons.add_circle_outline;
    if (act.contains('captured') || act.contains('scan')) return Icons.camera_alt_outlined;
    if (act.contains('exported') || act.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (act.contains('completed')) return Icons.check_circle_outline;
    if (act.contains('archive')) return Icons.archive_outlined;
    if (act.contains('delete')) return Icons.delete_outline;
    return Icons.history_outlined;
  }

  Color get _color {
    final act = event.action.toLowerCase();
    if (act.contains('created') || act.contains('completed')) return AppTheme.successColor;
    if (act.contains('captured')) return AppTheme.primaryColor;
    if (act.contains('exported')) return AppTheme.warningColor;
    if (act.contains('delete')) return AppTheme.errorColor;
    return AppTheme.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Rail Time Stamp & Indicator Node
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: _color, width: 1.5),
                ),
                child: Icon(_icon, size: 16, color: _color),
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

          // Content Box
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event.action,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                      ),
                      Text(
                        _formatTime(event.timestamp),
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.target,
                    style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  if (event.reason != null && event.reason!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Note: ${event.reason!}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    'Operator: ${event.operatorName}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                  ),
                ],
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
