import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/truck/data/services/live_camera_text_frame.dart';

void main() {
  test('rejects a uniformly dark frame region', () {
    final bytes = Uint8List(64 * 48)..fillRange(0, 64 * 48, 12);

    expect(
      lumaPlaneHasSufficientQuality(
        bytes,
        width: 64,
        height: 48,
        bytesPerRow: 64,
        roiWidthFraction: 0.8,
        roiHeightFraction: 0.5,
      ),
      isFalse,
    );
  });

  test('accepts a well-lit frame region with strong text-like edges', () {
    final bytes = Uint8List(64 * 48);
    for (var y = 0; y < 48; y++) {
      for (var x = 0; x < 64; x++) {
        bytes[y * 64 + x] = (x ~/ 2).isEven ? 55 : 205;
      }
    }

    expect(
      lumaPlaneHasSufficientQuality(
        bytes,
        width: 64,
        height: 48,
        bytesPerRow: 64,
        roiWidthFraction: 0.8,
        roiHeightFraction: 0.5,
      ),
      isTrue,
    );
  });
}
