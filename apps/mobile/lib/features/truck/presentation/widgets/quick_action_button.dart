import 'package:flutter/material.dart';
import '../../../../core/presentation/layout/responsive.dart';
import '../../../../theme/app_theme.dart';

/// A large full-width action button for the primary workspace actions.
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isOutlined;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppTheme.primaryColor;
    final fgColor = foregroundColor ?? Colors.white;

    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: fgColor,
            side: BorderSide(color: bgColor.withValues(alpha: 0.5)),
            padding: EdgeInsets.symmetric(
              vertical: AppResponsive.isCompact(context) ? 11 : 14,
              horizontal: AppResponsive.isCompact(context) ? 12 : 20,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppResponsive.text(context, 14),
                      )),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: TextStyle(
                            fontSize: 11,
                            color: fgColor.withValues(alpha: 0.7))),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          disabledBackgroundColor: AppTheme.dividerColor,
          disabledForegroundColor: AppTheme.textSecondary,
          padding: EdgeInsets.symmetric(
            vertical: AppResponsive.isCompact(context) ? 11 : 14,
            horizontal: AppResponsive.isCompact(context) ? 12 : 20,
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: onPressed == null ? 0 : 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppResponsive.text(context, 14),
                    )),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                        fontSize: 11, color: fgColor.withValues(alpha: 0.75)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
