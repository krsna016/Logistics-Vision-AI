import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/camera/presentation/providers/inference_state.dart';

void main() {
  test('shared AI runtime exposes explicit preparation states', () {
    const idle = InferenceState();
    expect(idle.modelStatus, InferenceModelStatus.idle);
    expect(idle.isModelLoaded, isFalse);

    final loading = idle.copyWith(modelStatus: InferenceModelStatus.loading);
    expect(loading.modelStatus, InferenceModelStatus.loading);

    final ready = loading.copyWith(
      modelStatus: InferenceModelStatus.ready,
      isModelLoaded: true,
    );
    expect(ready.modelStatus, InferenceModelStatus.ready);
    expect(ready.isModelLoaded, isTrue);
  });

  test('successful retry clears an earlier model error', () {
    final failed = const InferenceState().copyWith(
      modelStatus: InferenceModelStatus.error,
      errorMessage: 'failed',
    );
    final retried = failed.copyWith(
      modelStatus: InferenceModelStatus.loading,
      clearError: true,
    );
    expect(retried.errorMessage, isNull);
  });
}
