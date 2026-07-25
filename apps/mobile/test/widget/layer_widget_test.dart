import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/features/layer/presentation/screens/layer_review_screen.dart';
import 'package:mobile/features/layer/presentation/providers/layer_providers.dart';
import 'package:mobile/features/layer/domain/entities/layer.dart';

void main() {
  Widget buildTestableWidget(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: LayerReviewScreen(
          truckId: 'mock_t1',
          cartonCount: 36,
          averageConfidence: 0.945,
        ),
      ),
    );
  }

  group('LayerReviewScreen Widget Tests', () {
    testWidgets('Displays carton count and confidence banner correctly', (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          layerListProvider('mock_t1').overrideWith((ref) {
            return StateController(const LayerListState());
          } as StateNotifier Function(AutoDisposeStateNotifierProviderRef<LayerListNotifier, LayerListState>)),
        ],
      );

      await tester.pumpWidget(buildTestableWidget(container));
      await tester.pump();

      expect(find.text('36'), findsOneWidget);
      expect(find.text('AI Prediction Confidence: 95%'), findsOneWidget);
      expect(find.text('Confirm & Save Layer'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
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
