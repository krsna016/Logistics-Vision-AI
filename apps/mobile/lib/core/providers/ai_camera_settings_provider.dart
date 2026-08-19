import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai_engine/ai_camera_settings.dart';
import 'database_provider.dart';

/// Loads persisted AI controls once per app session before the model starts.
/// This prevents a restart from silently reverting to in-memory defaults.
final aiCameraSettingsLoaderProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(databaseProvider);
  final rows = await (db.select(db.settings)
        ..where((setting) => setting.key.equals('ai_camera')))
      .get();
  if (rows.isEmpty) return;

  try {
    final decoded = jsonDecode(rows.first.value);
    if (decoded is! Map<String, dynamic>) return;
    AiCameraSettings.apply(
      confidenceValue: (decoded['confidence'] as num?)?.toDouble() ?? .27,
      iouValue: (decoded['iou'] as num?)?.toDouble() ?? .70,
      cropQualityValue: (decoded['quality'] as num?)?.toInt() ?? 98,
      detailedMasksValue: decoded['masks'] as bool? ?? true,
      processingThreadsValue:
          (decoded['processingThreads'] as num?)?.toInt() ?? 4,
      showDatabaseIdsValue: decoded['showIds'] as bool? ?? false,
    );
  } catch (_) {
    // Corrupt legacy settings must not prevent camera/model startup. The
    // settings screen can overwrite them with validated values later.
  }
});
