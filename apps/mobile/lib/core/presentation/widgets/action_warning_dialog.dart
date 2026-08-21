import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ActionWarningDialog extends StatefulWidget {
  final String title;
  final String content;
  final String actionLabel;
  final Color actionColor;
  final Future<String?> Function() onConfirm;
  final IconData icon;

  const ActionWarningDialog({
    super.key,
    required this.title,
    required this.content,
    this.actionLabel = 'Confirm',
    this.actionColor = Colors.redAccent,
    required this.onConfirm,
    this.icon = Icons.warning_amber_rounded,
  });

  @override
  State<ActionWarningDialog> createState() => _ActionWarningDialogState();
}

class _ActionWarningDialogState extends State<ActionWarningDialog> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceColor,
      insetAnimationDuration: const Duration(milliseconds: 180),
      insetAnimationCurve: Curves.easeOutCubic,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.actionColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, color: widget.actionColor, size: 48),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppTheme.errorColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppTheme.errorColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              widget.content,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                          fontSize: 16, color: AppTheme.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            final error = await widget.onConfirm();
                            if (!context.mounted) return;
                            if (error != null) {
                              setState(() {
                                _isLoading = false;
                                _errorMessage = error;
                              });
                            } else {
                              Navigator.pop(context);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.actionColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.actionLabel,
                              maxLines: 1,
                              softWrap: false,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
