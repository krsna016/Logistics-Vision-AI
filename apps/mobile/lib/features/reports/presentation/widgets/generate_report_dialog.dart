import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class GenerateReportDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final Future<void> Function() onPdf;
  final Future<void> Function() onExcel;

  const GenerateReportDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onPdf,
    required this.onExcel,
  });

  @override
  State<GenerateReportDialog> createState() => _GenerateReportDialogState();
}

class _GenerateReportDialogState extends State<GenerateReportDialog> {
  String? _generatingFormat;

  Future<void> _generate(String format, Future<void> Function() action) async {
    if (_generatingFormat != null) return;
    setState(() => _generatingFormat = format);
    try {
      // Let Flutter paint the selected button's spinner before report
      // generation starts doing any database or document work.
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(Duration.zero);
      if (!mounted) return;
      await action();
    } finally {
      if (mounted) {
        setState(() => _generatingFormat = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF102A43), Color(0xFF173D5C)],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.assessment_outlined,
                          color: AppTheme.primaryColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(widget.title,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.subtitle,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, height: 1.4)),
                    const SizedBox(height: 18),
                    _ReportOptionButton(
                      icon: Icons.picture_as_pdf_outlined,
                      title: 'Export PDF',
                      subtitle: 'Best for printing and sharing',
                      color: AppTheme.primaryColor,
                      isLoading: _generatingFormat == 'PDF',
                      onPressed: _generatingFormat == null
                          ? () => _generate('PDF', widget.onPdf)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    _ReportOptionButton(
                      icon: Icons.table_chart_outlined,
                      title: 'Export Excel',
                      subtitle: 'Best for editing and analysis',
                      color: AppTheme.successColor,
                      isLoading: _generatingFormat == 'Excel',
                      onPressed: _generatingFormat == null
                          ? () => _generate('Excel', widget.onExcel)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportOptionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isLoading;
  final Future<void> Function()? onPressed;

  const _ReportOptionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onPressed == null ? null : () => onPressed!(),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 23),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  Text(subtitle,
                      style:
                          const TextStyle(fontSize: 11, color: Colors.white70)),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            else
              const Icon(Icons.arrow_forward_rounded, size: 19),
          ],
        ),
      ),
    );
  }
}
