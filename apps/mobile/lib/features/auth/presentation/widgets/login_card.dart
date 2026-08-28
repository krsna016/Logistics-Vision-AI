import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_theme.dart';
import '../../../../core/presentation/layout/responsive.dart';
import '../providers/auth_providers.dart';
import '../../../camera/presentation/providers/inference_notifier.dart';
import '../../../../utils/logger.dart';
import '../../../../config/environment.dart';

class LoginCard extends ConsumerStatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginCard({super.key, required this.onLoginSuccess});

  @override
  ConsumerState<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends ConsumerState<LoginCard> {
  final _employeeIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _employeeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    await _authenticate();
  }

  Future<void> _authenticate() async {
    setState(() => _isLoading = true);
    final inferenceNotifier = ref.read(inferenceNotifierProvider.notifier);
    final success = await ref.read(authProvider.notifier).login(
          _employeeIdController.text,
          _passwordController.text,
        );
    if (success) {
      _completeEntry(inferenceNotifier);
    } else {
      if (!mounted) return;
      final errorMessage = ref.read(authProvider.notifier).loginErrorMessage;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _handleLocalAdministratorEntry() async {
    setState(() => _isLoading = true);
    final inferenceNotifier = ref.read(inferenceNotifierProvider.notifier);
    await ref.read(authProvider.notifier).enterLocalAdministrator();
    if (!mounted) return;
    _completeEntry(inferenceNotifier);
  }

  void _completeEntry(InferenceNotifier inferenceNotifier) {
    if (mounted) {
      setState(() => _isLoading = false);
      widget.onLoginSuccess();
    }
    // The dashboard does not need the carton-counting model. Warm it after
    // navigation so loading a large ONNX asset is never presented as login
    // time. Capture still awaits the same shared initialization if necessary.
    unawaited(Future<void>.delayed(Duration.zero, () async {
      try {
        await inferenceNotifier.ensureModelReady();
      } catch (error, stack) {
        AppLogger.error('Post-login AI preparation failed', error, stack);
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppResponsive.contentWidth(context, max: 400),
      padding: EdgeInsets.all(AppResponsive.isCompact(context) ? 20 : 32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.security, size: 48, color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          const Text(
            'Authentication',
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          TextField(
            controller: _employeeIdController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Employee ID',
              prefixIcon:
                  const Icon(Icons.badge, color: AppTheme.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppTheme.backgroundColor,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock, color: AppTheme.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppTheme.backgroundColor,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Sign In',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white)),
            ),
          ),
          if (Environment.enableLocalAdministratorEntry) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleLocalAdministratorEntry,
                icon: const Icon(Icons.admin_panel_settings_outlined),
                label: const Text(
                  'Enter as Administrator',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
