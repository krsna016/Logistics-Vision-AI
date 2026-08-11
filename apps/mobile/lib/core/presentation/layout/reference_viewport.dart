import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Normalizes SmartLoad's visual density against the approved reference phone.
///
/// The reference device renders Flutter at 2.4 logical pixels per physical
/// pixel. Some Android phones use 3.0 or more for the same physical panel,
/// which makes an identical logical layout look materially larger. This
/// viewport gives those devices more logical layout space and scales the
/// finished frame back to the real screen, keeping typography, cards, icons,
/// spacing, touch regions, safe areas, and keyboard insets in one coordinate
/// system.
class SmartLoadReferenceViewport extends StatelessWidget {
  static const double referenceDevicePixelRatio = 2.4;
  static const double minimumScale = 0.68;

  final Widget child;

  const SmartLoadReferenceViewport({
    super.key,
    required this.child,
  });

  @visibleForTesting
  static double scaleForDevicePixelRatio(double devicePixelRatio) {
    if (!devicePixelRatio.isFinite || devicePixelRatio <= 0) return 1;
    return (referenceDevicePixelRatio / devicePixelRatio)
        .clamp(minimumScale, 1.0);
  }

  static EdgeInsets _expandInsets(EdgeInsets insets, double scale) =>
      EdgeInsets.fromLTRB(
        insets.left / scale,
        insets.top / scale,
        insets.right / scale,
        insets.bottom / scale,
      );

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Foldable hinges use physical display coordinates. Until each display
    // segment can be normalized independently, preserve Flutter's native
    // geometry rather than moving a hinge or cutout boundary.
    final scale = media.displayFeatures.isEmpty
        ? scaleForDevicePixelRatio(media.devicePixelRatio)
        : 1.0;
    final virtualSize = Size(
      media.size.width / scale,
      media.size.height / scale,
    );
    final systemTextScale = media.textScaler.scale(1).clamp(0.92, 1.03);
    final widthTextScale = (virtualSize.width / 390).clamp(0.92, 1.03);
    final textScale = math.min(systemTextScale, widthTextScale);
    final normalizedMedia = media.copyWith(
      size: virtualSize,
      padding: _expandInsets(media.padding, scale),
      viewPadding: _expandInsets(media.viewPadding, scale),
      viewInsets: _expandInsets(media.viewInsets, scale),
      systemGestureInsets: _expandInsets(media.systemGestureInsets, scale),
      textScaler: TextScaler.linear(textScale),
    );

    if (scale == 1) {
      return MediaQuery(data: normalizedMedia, child: child);
    }

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.topLeft,
        minWidth: virtualSize.width,
        maxWidth: virtualSize.width,
        minHeight: virtualSize.height,
        maxHeight: virtualSize.height,
        child: Transform.scale(
          alignment: Alignment.topLeft,
          scale: scale,
          child: SizedBox.fromSize(
            size: virtualSize,
            child: MediaQuery(data: normalizedMedia, child: child),
          ),
        ),
      ),
    );
  }
}
