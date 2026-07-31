import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/defect.dart';
import '../../domain/entities/quality_summary.dart';
import '../../domain/repositories/defect_repository.dart';
import '../../data/repositories_impl/local_defect_repository.dart';
import '../../../../utils/logger.dart';

final defectRepositoryProvider = Provider<DefectRepository>((ref) {
  return LocalDefectRepository();
});

class DefectListState {
  final List<DefectRecord> defects;
  final bool isLoading;
  final String? errorMessage;

  const DefectListState({
    this.defects = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  DefectListState copyWith({
    List<DefectRecord>? defects,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DefectListState(
      defects: defects ?? this.defects,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DefectListNotifier extends StateNotifier<DefectListState> {
  final DefectRepository _repository;
  final String _layerId;

  DefectListNotifier(this._repository, this._layerId)
      : super(const DefectListState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _repository.getDefectsByLayer(_layerId);
      state =
          state.copyWith(defects: list, isLoading: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: 'Failed to read defects list.');
    }
  }

  Future<void> saveDefect(DefectRecord defect) async {
    try {
      await _repository.saveDefect(defect);
      await refresh();
    } catch (e) {
      AppLogger.error('Failed to save defect', e);
    }
  }

  Future<void> verifyDefect(String id,
      {required bool confirmed, String? notes}) async {
    try {
      await _repository.verifyDefect(id,
          confirmedByOperator: confirmed, notes: notes);
      await refresh();
      AppLogger.info('Operator verified defect $id: confirmed=$confirmed');
    } catch (e) {
      AppLogger.error('Failed to verify defect', e);
    }
  }
}

// Auto-disposed StateNotifierProvider parameterized by layerId
final defectListProvider = StateNotifierProvider.family
    .autoDispose<DefectListNotifier, DefectListState, String>((ref, layerId) {
  final repo = ref.watch(defectRepositoryProvider);
  return DefectListNotifier(repo, layerId);
});

// Provider to compute QualitySummary of a layer
final layerQualityProvider =
    Provider.family.autoDispose<QualitySummary, (int, String)>((ref, arg) {
  final (cartonCount, layerId) = arg;
  final defectState = ref.watch(defectListProvider(layerId));

  final confirmedDefectsCount =
      defectState.defects.where((d) => d.confirmedByOperator).length;

  return QualitySummary(
    totalCartons: cartonCount,
    defectiveCartons: confirmedDefectsCount,
    defects: defectState.defects,
  );
});
