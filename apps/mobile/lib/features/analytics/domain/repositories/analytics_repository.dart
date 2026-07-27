import '../entities/time_filter.dart';
import '../entities/analytics_summary.dart';
import '../entities/performance_metrics.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsSummary> getSummary(TimeFilter filter);
  Future<AIPerformanceMetrics> getAIPerformance(TimeFilter filter);
  Future<LoadingPerformanceMetrics> getLoadingPerformance(TimeFilter filter);
  Future<DatasetHealthMetrics> getDatasetHealth(TimeFilter filter);
  Future<ProductivityMetrics> getProductivityMetrics(TimeFilter filter);
  
  // Future reports generation placeholder
  Future<String> generatePdfReport(TimeFilter filter);
  Future<String> generateExcelReport(TimeFilter filter);
}
