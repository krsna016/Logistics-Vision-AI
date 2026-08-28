import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Renders SmartLoad through the same logical-width canvas as the approved
/// reference phone.
///
/// The reference device is 1220 physical pixels wide with Android's display
/// density overridden to 384 dpi. Flutter therefore exposes a
/// 508.333-logical-pixel-wide window (1220 / (384 / 160)). A conventional
/// phone commonly exposes only 360--430 logical pixels, which otherwise makes
/// every fixed-size control occupy a much larger fraction of the display.
///
/// On narrower phones we lay the app out at the reference width, then scale
/// the complete frame down uniformly. Insets and hit testing participate in
/// the same transform. Wider displays retain a centered, reference-width
/// workspace instead of stretching the phone UI.
class SmartLoadReferenceViewport extends StatelessWidget {
  static const double referencePhysicalWidth = 1220;
  static const double referenceDensityDpi = 384;
  static const double referenceLogicalWidth =
      referencePhysicalWidth / (referenceDensityDpi / 160);

  final Widget child;

  const SmartLoadReferenceViewport({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final workspaceWidth = math.min(media.size.width, referenceLogicalWidth);
    final scale = workspaceWidth / referenceLogicalWidth;
    final virtualHeight = media.size.height / scale;

    EdgeInsets inverseScale(EdgeInsets value) => EdgeInsets.fromLTRB(
          value.left / scale,
          value.top / scale,
          value.right / scale,
          value.bottom / scale,
        );

    final normalizedMedia = media.copyWith(
      size: Size(referenceLogicalWidth, virtualHeight),
      padding: inverseScale(media.padding),
      viewPadding: inverseScale(media.viewPadding),
      viewInsets: inverseScale(media.viewInsets),
      systemGestureInsets: inverseScale(media.systemGestureInsets),
      textScaler: TextScaler.noScaling,
      displayFeatures: const [],
    );

    final viewport = SizedBox(
      width: referenceLogicalWidth,
      height: virtualHeight,
      child: MediaQuery(data: normalizedMedia, child: child),
    );

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: workspaceWidth,
          height: media.size.height,
          child: ClipRect(
            child: FittedBox(
              alignment: Alignment.topLeft,
              fit: BoxFit.fill,
              child: viewport,
            ),
          ),
        ),
      ),
    );
  }
}
