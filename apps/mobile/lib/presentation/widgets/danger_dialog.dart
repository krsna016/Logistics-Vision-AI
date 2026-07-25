import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class DangerDialog extends StatefulWidget {
  final String title;
  final String confirmMatchString;
  final String matchLabel;
  final List<String> warningBulletPoints;
  final String confirmButtonText;
  final VoidCallback onConfirm;

  const DangerDialog({
    super.key,
    required this.title,
    required this.confirmMatchString,
    required this.matchLabel,
    required this.warningBulletPoints,
    required this.confirmButtonText,
    required this.onConfirm,
  });

  @override
  State<DangerDialog> createState() => _DangerDialogState();
}

class _DangerDialogState extends State<DangerDialog> {
  final TextEditingController _inputController = TextEditingController();
  bool _isMatch = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.errorColor, width: 1.5),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This action is destructive and cannot be undone. Associated items that will be permanently removed:',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ...widget.warningBulletPoints.map(
              (point) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  children: [
                    const Icon(Icons.close, color: AppTheme.errorColor, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                children: [
                  TextSpan(text: widget.matchLabel),
                  TextSpan(
                    text: ' "${widget.confirmMatchString}" ',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const TextSpan(text: 'to enable the delete button:'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _inputController,
              autofocus: true,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              decoration: InputDecoration(
                hintText: widget.confirmMatchString,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _isMatch = val.trim() == widget.confirmMatchString.trim();
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _isMatch
              ? () {
                  Navigator.pop(context);
                  widget.onConfirm();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
            disabledBackgroundColor: AppTheme.errorColor.withOpacity(0.3),
            foregroundColor: Colors.white,
          ),
          child: Text(widget.confirmButtonText),
        ),
      ],
    );
  }
}
