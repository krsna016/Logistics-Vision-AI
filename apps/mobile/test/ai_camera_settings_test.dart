import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:mobile/core/ai_engine/ai_camera_settings.dart';
import 'package:mobile/core/database/app_database.dart';
import 'package:mobile/core/providers/ai_camera_settings_provider.dart';
import 'package:mobile/core/providers/database_provider.dart';
import 'package:mobile/core/storage/image_storage_service.dart';
import 'package:mobile/features/layer/domain/entities/layer.dart';

void main() {
  tearDown(() {
    AiCameraSettings.apply(
      confidenceValue: .27,
      iouValue: .70,
      cropQualityValue: 98,
      detailedMasksValue: true,
      processingThreadsValue: 4,
    );
  });

  test('uses the fixed high-detail model input', () {
    expect(AiCameraSettings.modelInputSize, 960);
  });

  test('accepts 100 percent confidence and JPEG quality', () {
    AiCameraSettings.apply(
      confidenceValue: 1,
      iouValue: .95,
      cropQualityValue: 100,
      detailedMasksValue: false,
      processingThreadsValue: 4,
    );

    expect(AiCameraSettings.confidence.value, 1);
    expect(AiCameraSettings.iou.value, .95);
    expect(AiCameraSettings.cropQuality.value, 100);
    expect(AiCameraSettings.detailedMasks.value, isFalse);
    expect(AiCameraSettings.processingThreads.value, 4);
  });

  test('clamps unsafe values and selects supported CPU worker counts', () {
    AiCameraSettings.apply(
      confidenceValue: -1,
      iouValue: 4,
      cropQualityValue: 300,
      detailedMasksValue: true,
      processingThreadsValue: 3,
    );

    expect(AiCameraSettings.confidence.value, .05);
    expect(AiCameraSettings.iou.value, .95);
    expect(AiCameraSettings.cropQuality.value, 100);
    expect(AiCameraSettings.processingThreads.value, 2);
  });

  test('loads every persisted AI setting before model startup', () async {
    final documents =
        await Directory.systemTemp.createTemp('smartload_ai_settings_');
    final database = AppDatabase.forTesting(
      NativeDatabase(File('${documents.path}/settings.sqlite')),
    );
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(database),
    ]);
    addTearDown(() async {
      container.dispose();
      await database.close();
      await documents.delete(recursive: true);
    });
    await database.into(database.settings).insert(
          SettingsCompanion.insert(
            key: 'ai_camera',
            value: jsonEncode({
              'confidence': .42,
              'iou': .81,
              'quality': 91,
              'masks': false,
              'processingThreads': 2,
            }),
          ),
        );

    await container.read(aiCameraSettingsLoaderProvider.future);

    expect(AiCameraSettings.confidence.value, .42);
    expect(AiCameraSettings.iou.value, .81);
    expect(AiCameraSettings.cropQuality.value, 91);
    expect(AiCameraSettings.detailedMasks.value, isFalse);
    expect(AiCameraSettings.processingThreads.value, 2);
  });

  test('crop JPEG quality changes the actual encoded AI crop', () async {
    final image = img.Image(width: 128, height: 128);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        image.setPixelRgba(
          x,
          y,
          (x * 17 + y * 3) % 256,
          (x * 5 + y * 19) % 256,
          (x * 13 + y * 11) % 256,
          255,
        );
      }
    }
    final source = Uint8List.fromList(img.encodeJpg(image, quality: 100));
    final region = CountingRegion.rectangle(
      left: 0,
      top: 0,
      right: 1,
      bottom: 1,
    );
    final service = ImageStorageService();

    AiCameraSettings.cropQuality.value = 85;
    final standard =
        await service.createCountingCropBytesFromBytes(source, region);
    AiCameraSettings.cropQuality.value = 100;
    final maximum =
        await service.createCountingCropBytesFromBytes(source, region);

    expect(img.decodeImage(standard), isNotNull);
    expect(img.decodeImage(maximum), isNotNull);
    expect(maximum.length, greaterThan(standard.length));
  });
}
