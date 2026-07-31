import 'package:flutter/material.dart';
import '../../core/presentation/layout/responsive.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? elevation;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Padding(
      padding: padding ?? EdgeInsets.all(AppResponsive.cardPadding(context)),
      child: child,
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: cardContent,
      );
    }

    return Card(
      elevation: elevation ?? 2.0,
      clipBehavior: Clip.antiAlias,
      child: cardContent,
    );
  }
}
