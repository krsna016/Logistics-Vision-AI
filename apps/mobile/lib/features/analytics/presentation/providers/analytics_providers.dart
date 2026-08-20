import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/time_filter.dart';
import '../../domain/entities/analytics_summary.dart';
import '../../domain/entities/performance_metrics.dart';
import '../../domain/entities/analytics_snapshot.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../data/repositories_impl/local_analytics_repository.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../wagon/presentation/providers/wagon_providers.dart';
import '../../../truck/presentation/providers/truck_providers.dart';
import '../../../layer/presentation/providers/layer_providers.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final wagonRepo = ref.watch(wagonRepositoryProvider);
  final truckRepo = ref.watch(truckRepositoryProvider);
  final layerRepo = ref.watch(layerRepositoryProvider);
  return LocalAnalyticsRepository(
    wagonRepo,
    truckRepo,
    layerRepo,
    database: ref.watch(databaseProvider),
  );
});

final timeFilterProvider = StateProvider<TimeFilter>((ref) => TimeFilter.today);

final analyticsSnapshotProvider =
    FutureProvider<AnalyticsSnapshot>((ref) async {
  final filter = ref.watch(timeFilterProvider);
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getSnapshot(filter);
});

final analyticsSummaryProvider = Provider<AsyncValue<AnalyticsSummary>>((ref) {
  return ref.watch(analyticsSnapshotProvider).whenData((data) => data.summary);
});

final aiPerformanceProvider = Provider<AsyncValue<AIPerformanceMetrics>>((ref) {
  return ref
      .watch(analyticsSnapshotProvider)
      .whenData((data) => data.aiPerformance);
});

final loadingPerformanceProvider =
    Provider<AsyncValue<LoadingPerformanceMetrics>>((ref) {
  return ref
      .watch(analyticsSnapshotProvider)
      .whenData((data) => data.loadingPerformance);
});

final datasetHealthProvider = Provider<AsyncValue<DatasetHealthMetrics>>((ref) {
  return ref
      .watch(analyticsSnapshotProvider)
      .whenData((data) => data.datasetHealth);
});

final productivityProvider = Provider<AsyncValue<ProductivityMetrics>>((ref) {
  return ref
      .watch(analyticsSnapshotProvider)
      .whenData((data) => data.productivity);
});
