import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class StrictActionWarningDialog extends StatefulWidget {
  final String title;
  final String content;
  final String expectedConfirmationText;
  final String actionLabel;
  final Color actionColor;
  final VoidCallback onConfirm;
  final IconData icon;

  const StrictActionWarningDialog({
    super.key,
    required this.title,
    required this.content,
    required this.expectedConfirmationText,
    this.actionLabel = 'Confirm',
    this.actionColor = Colors.redAccent,
    required this.onConfirm,
    this.icon = Icons.warning_amber_rounded,
  });

  @override
  State<StrictActionWarningDialog> createState() => _StrictActionWarningDialogState();
}

class _StrictActionWarningDialogState extends State<StrictActionWarningDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isMatch = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    setState(() {
      _isMatch = text.trim() == widget.expectedConfirmationText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceColor,
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
            const SizedBox(height: 24),
            Text(
              'Type "${widget.expectedConfirmationText}" to confirm:',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              onChanged: _onTextChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: widget.expectedConfirmationText,
                filled: true,
                fillColor: AppTheme.cardColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.actionColor),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isMatch
                        ? () {
                            Navigator.pop(context);
                            widget.onConfirm();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.actionColor,
                      disabledBackgroundColor: widget.actionColor.withValues(alpha: 0.3),
                      disabledForegroundColor: Colors.white.withValues(alpha: 0.3),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.actionLabel,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
