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
  static const double minimumScale = 0.60;
  static const double maximumWorkspaceWidth = 520;
  static const double tabletShortestSide = 600;

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

  static MediaQueryData _normalizedMedia({
    required MediaQueryData media,
    required Size size,
    required double scale,
    required double textWidth,
    bool removeHorizontalInsets = false,
  }) {
    final systemTextScale = media.textScaler.scale(1).clamp(0.92, 1.03);
    final widthTextScale = (textWidth / 390).clamp(0.92, 1.03);
    final textScale = math.min(systemTextScale, widthTextScale);
    EdgeInsets insets(EdgeInsets value) {
      final expanded = _expandInsets(value, scale);
      return removeHorizontalInsets
          ? EdgeInsets.only(top: expanded.top, bottom: expanded.bottom)
          : expanded;
    }

    return media.copyWith(
      size: size,
      padding: insets(media.padding),
      viewPadding: insets(media.viewPadding),
      viewInsets: insets(media.viewInsets),
      systemGestureInsets: insets(media.systemGestureInsets),
      textScaler: TextScaler.linear(textScale),
      // A centered phone workspace must not inherit a hinge positioned in the
      // full display's coordinate system.
      displayFeatures: removeHorizontalInsets ? const [] : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Foldable hinges use physical display coordinates. Until each display
    // segment can be normalized independently, preserve Flutter's native
    // geometry rather than moving a hinge or cutout boundary.
    final isLargeOrSegmented = media.size.shortestSide >= tabletShortestSide ||
        media.displayFeatures.isNotEmpty;
    final scale = media.displayFeatures.isEmpty
        ? scaleForDevicePixelRatio(media.devicePixelRatio)
        : 1.0;
    final virtualSize = Size(
      media.size.width / scale,
      media.size.height / scale,
    );
    final workspaceWidth = isLargeOrSegmented
        ? math.min(maximumWorkspaceWidth, virtualSize.width)
        : virtualSize.width;
    final workspaceSize = Size(workspaceWidth, virtualSize.height);
    final normalizedMedia = _normalizedMedia(
      media: media,
      size: workspaceSize,
      scale: scale,
      textWidth: workspaceWidth,
      removeHorizontalInsets: isLargeOrSegmented,
    );

    final normalizedChild = MediaQuery(data: normalizedMedia, child: child);
    final workspace = isLargeOrSegmented
        ? ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: workspaceWidth,
                height: virtualSize.height,
                child: normalizedChild,
              ),
            ),
          )
        : normalizedChild;

    if (scale == 1) {
      return workspace;
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
            child: workspace,
          ),
        ),
      ),
    );
  }
}
