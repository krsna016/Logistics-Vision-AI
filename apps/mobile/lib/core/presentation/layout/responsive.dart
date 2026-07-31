import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shared layout values for phones with different widths, densities, and
/// system display settings.
class AppResponsive {
  const AppResponsive._();

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double height(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static bool isCompact(BuildContext context) => width(context) < 360;
  static bool isNarrow(BuildContext context) => width(context) < 380;
  static bool isTablet(BuildContext context) => width(context) >= 600;

  static double pagePadding(BuildContext context) =>
      math.min(24, math.max(16, width(context) * 0.05));

  static double scale(BuildContext context, double value,
      {double min = 0.9, double max = 1.08}) {
    final factor = width(context) / 390;
    return value * factor.clamp(min, max);
  }

  static double contentWidth(BuildContext context, {double max = 520}) =>
      math.min(max, width(context) - (pagePadding(context) * 2));

  static double cardPadding(BuildContext context) {
    if (isCompact(context)) return 14;
    if (isTablet(context)) return 20;
    return 16;
  }

  static double gap(BuildContext context, {double normal = 12}) {
    if (isCompact(context)) return math.max(8, normal - 4);
    if (isTablet(context)) return normal + 4;
    return normal;
  }

  static double text(BuildContext context, double value,
          {double min = 0.92, double max = 1.04}) =>
      scale(context, value, min: min, max: max);
}
