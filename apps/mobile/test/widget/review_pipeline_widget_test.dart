import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/features/layer/presentation/screens/layer_review_screen.dart';
import 'package:mobile/features/layer/presentation/providers/layer_providers.dart';
import 'package:mobile/features/layer/domain/entities/ai_result.dart';

void main() {
  Widget buildTestableWidget(ProviderContainer container, AIResult aiResult) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: LayerReviewScreen(
          truckId: 'mock_t1',
          aiResult: aiResult,
          photoPath: null, // Null to test fallback placeholder
        ),
      ),
    );
  }

  group('LayerReviewScreen Pipeline Widget Tests', () {
    testWidgets('Renders placeholder and overlay bounding boxes on freeze frame', (WidgetTester tester) async {
      final aiResult = AIResult(
        detections: const [],
        count: 18,
        averageConfidence: 0.96,
        processingTimeMs: 14.0,
        modelVersion: '1.0.0-YOLOv8n',
        inferenceTimestamp: DateTime.now(),
        frameSize: const Size(640, 640),
      );

      final container = ProviderContainer(
        overrides: [
          layerListProvider('mock_t1').overrideWith((ref) {
            return StateController(const LayerListState());
          }),
        ],
      );

      await tester.pumpWidget(buildTestableWidget(container, aiResult));
      await tester.pump();

      // Assert placeholder and metrics render
      expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);
      expect(find.text('18'), findsWidgets);
      expect(find.text('CONF'), findsOneWidget);
      expect(find.text('96.0%'), findsOneWidget);
      expect(find.text('Confirm  18 Cartons'), findsOneWidget);
    });
  });
}

// Simple mock StateNotifier for routing test state overrides
class StateController extends StateNotifier<LayerListState> implements LayerListNotifier {
  StateController(super.state);

  @override
  Future<void> refresh() async {}

  @override
  Future<String?> saveLayer({
    required int cartonCount,
    required double confidence,
    String? notes,
    String? photoPath,
  }) async => null;

  @override
  Future<String?> editNotes(String layerId, String? nextNotes) async => null;

  @override
  Future<void> deleteLayer(String id) async {}
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
