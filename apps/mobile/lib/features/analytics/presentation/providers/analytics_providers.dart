import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/time_filter.dart';
import '../../domain/entities/analytics_summary.dart';
import '../../domain/entities/performance_metrics.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../data/repositories_impl/local_analytics_repository.dart';
import '../../../wagon/presentation/providers/wagon_providers.dart';
import '../../../truck/presentation/providers/truck_providers.dart';
import '../../../layer/presentation/providers/layer_providers.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final wagonRepo = ref.watch(wagonRepositoryProvider);
  final truckRepo = ref.watch(truckRepositoryProvider);
  final layerRepo = ref.watch(layerRepositoryProvider);
  return LocalAnalyticsRepository(wagonRepo, truckRepo, layerRepo);
});

final timeFilterProvider = StateProvider<TimeFilter>((ref) => TimeFilter.today);

final analyticsSummaryProvider = FutureProvider<AnalyticsSummary>((ref) async {
  final filter = ref.watch(timeFilterProvider);
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getSummary(filter);
});

final aiPerformanceProvider = FutureProvider<AIPerformanceMetrics>((ref) async {
  final filter = ref.watch(timeFilterProvider);
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getAIPerformance(filter);
});

final loadingPerformanceProvider =
    FutureProvider<LoadingPerformanceMetrics>((ref) async {
  final filter = ref.watch(timeFilterProvider);
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getLoadingPerformance(filter);
});

final datasetHealthProvider = FutureProvider<DatasetHealthMetrics>((ref) async {
  final filter = ref.watch(timeFilterProvider);
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getDatasetHealth(filter);
});

final productivityProvider = FutureProvider<ProductivityMetrics>((ref) async {
  final filter = ref.watch(timeFilterProvider);
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getProductivityMetrics(filter);
});
