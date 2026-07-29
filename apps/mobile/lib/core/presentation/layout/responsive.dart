import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shared layout values for phones with different widths, densities, and
/// system display settings.
class AppResponsive {
  const AppResponsive._();

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  static bool isCompact(BuildContext context) => width(context) < 360;

  static double pagePadding(BuildContext context) =>
      math.min(24, math.max(16, width(context) * 0.05));

  static double scale(BuildContext context, double value,
      {double min = 0.9, double max = 1.08}) {
    final factor = width(context) / 390;
    return value * factor.clamp(min, max);
  }

  static double contentWidth(BuildContext context, {double max = 520}) =>
      math.min(max, width(context) - (pagePadding(context) * 2));
}
