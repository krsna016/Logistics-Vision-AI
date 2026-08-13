import 'dart:async';

import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Protects data-entry routes from accidental system/gesture back navigation.
class UnsavedChangesGuard extends StatefulWidget {
  final bool hasUnsavedChanges;
  final bool isSaving;
  final Widget child;
  final String message;
  final FutureOr<void> Function()? onDiscardConfirmed;

  const UnsavedChangesGuard({
    super.key,
    required this.hasUnsavedChanges,
    required this.isSaving,
    required this.child,
    this.message = 'Your unsaved changes will be lost.',
    this.onDiscardConfirmed,
  });

  @override
  State<UnsavedChangesGuard> createState() => _UnsavedChangesGuardState();

  static Future<bool> confirmExit(
    BuildContext context, {
    required bool hasUnsavedChanges,
    required bool isSaving,
    String message = 'Your unsaved changes will be lost.',
  }) async {
    if (isSaving) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Please wait while changes are saved.')),
      );
      return false;
    }
    if (!hasUnsavedChanges) return true;
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor),
                SizedBox(width: 10),
                Expanded(child: Text('Discard changes?')),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Continue Editing'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor),
                child: const Text('Discard Changes'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _UnsavedChangesGuardState extends State<UnsavedChangesGuard> {
  bool _allowPop = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowPop || (!widget.isSaving && !widget.hasUnsavedChanges),
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await UnsavedChangesGuard.confirmExit(
          context,
          hasUnsavedChanges: widget.hasUnsavedChanges,
          isSaving: widget.isSaving,
          message: widget.message,
        );
        if (shouldExit && context.mounted) {
          await widget.onDiscardConfirmed?.call();
          if (!context.mounted) return;
          setState(() => _allowPop = true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.of(context).pop(result);
          });
        }
      },
      child: widget.child,
    );
  }
}
