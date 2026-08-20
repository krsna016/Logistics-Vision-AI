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
  static const double maximumWorkspaceWidth = 520;
  static const double tabletShortestSide = 600;

  final Widget child;

  const SmartLoadReferenceViewport({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isLargeOrSegmented = media.size.shortestSide >= tabletShortestSide ||
        media.displayFeatures.isNotEmpty;

    final workspaceWidth = isLargeOrSegmented
        ? math.min(maximumWorkspaceWidth, media.size.width)
        : media.size.width;

    // We rely purely on Flutter's native logical pixels (which are already density-independent).
    // We only lock the text scaling to 1.0 to prevent system font sizes from breaking the UI.
    final normalizedMedia = media.copyWith(
      textScaler: TextScaler.noScaling,
      size: Size(workspaceWidth, media.size.height),
      displayFeatures: isLargeOrSegmented ? const [] : null,
    );

    final normalizedChild = MediaQuery(data: normalizedMedia, child: child);

    if (isLargeOrSegmented) {
      return ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: workspaceWidth,
            child: normalizedChild,
          ),
        ),
      );
    }

    return normalizedChild;
  }
}
