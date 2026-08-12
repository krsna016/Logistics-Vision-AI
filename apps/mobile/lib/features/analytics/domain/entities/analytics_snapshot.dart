import 'analytics_summary.dart';
import 'performance_metrics.dart';

/// All analytics values derived from one consistent local database read.
///
/// Keeping these values together prevents each dashboard card from repeating
/// the same truck and layer queries.
class AnalyticsSnapshot {
  final AnalyticsSummary summary;
  final AIPerformanceMetrics aiPerformance;
  final LoadingPerformanceMetrics loadingPerformance;
  final DatasetHealthMetrics datasetHealth;
  final ProductivityMetrics productivity;

  const AnalyticsSnapshot({
    required this.summary,
    required this.aiPerformance,
    required this.loadingPerformance,
    required this.datasetHealth,
    required this.productivity,
  });
}
