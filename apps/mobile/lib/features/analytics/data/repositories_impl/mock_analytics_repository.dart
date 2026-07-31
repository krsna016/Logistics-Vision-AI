import 'dart:math';

import '../../domain/entities/time_filter.dart';
import '../../domain/entities/analytics_summary.dart';
import '../../domain/entities/performance_metrics.dart';
import '../../domain/repositories/analytics_repository.dart';

class MockAnalyticsRepository implements AnalyticsRepository {
  final Random _rnd = Random();

  @override
  Future<AnalyticsSummary> getSummary(TimeFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final multiplier = _getMultiplier(filter);

    return AnalyticsSummary(
      totalWagons: (2 * multiplier).round(),
      totalTrucks: (8 * multiplier).round(),
      totalLayers: (35 * multiplier).round(),
      totalCartons: (2800 * multiplier).round(),
      averageConfidence: 0.88 + (_rnd.nextDouble() * 0.05),
      averageLoadingTime: Duration(minutes: 45 + _rnd.nextInt(15)),
    );
  }

  @override
  Future<AIPerformanceMetrics> getAIPerformance(TimeFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return AIPerformanceMetrics(
      averageConfidence: 0.91,
      inferenceTimeMs: 14.5,
      fps: 28.5,
      manualCorrections: (15 * _getMultiplier(filter)).round(),
      rejectedDetections: (42 * _getMultiplier(filter)).round(),
      retakeRate: 0.03,
      detectionSuccessRate: 0.98,
      activeModelVersion: 'YOLO11s v1.0',
    );
  }

  @override
  Future<LoadingPerformanceMetrics> getLoadingPerformance(
      TimeFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return LoadingPerformanceMetrics(
      cartonsLoadedPerHour: 185.0,
      averageLayersPerTruck: 4.5,
      averageTruckCompletionTime: const Duration(minutes: 45),
      averageWagonCompletionTime: const Duration(hours: 4, minutes: 30),
      averageCartonsPerLayer: 55,
      hourlyCartonTrend:
          List.generate(24, (i) => 120.0 + _rnd.nextDouble() * 80),
    );
  }

  @override
  Future<DatasetHealthMetrics> getDatasetHealth(TimeFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final multi = _getMultiplier(filter);
    return DatasetHealthMetrics(
      imagesCaptured: (500 * multi).round(),
      approvedImages: (450 * multi).round(),
      rejectedImages: (30 * multi).round(),
      exportedImages: (400 * multi).round(),
      pendingReview: (20 * multi).round(),
      storageUsedMB: 1024.5 * multi,
      blurPercentage: 0.05,
      lightingIssues: 0.02,
      dailyCaptureTrend: List.generate(7, (i) => 40.0 + _rnd.nextDouble() * 50),
    );
  }

  @override
  Future<ProductivityMetrics> getProductivityMetrics(TimeFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const ProductivityMetrics(
      averageOperatorPerformance: 0.92,
      truckThroughput: 8.5,
      averageLayersPerHour: 5.2,
      averageCartonsPerHour: 195.0,
      averageSessionDuration: Duration(minutes: 55),
    );
  }

  @override
  Future<String> generatePdfReport(TimeFilter filter) async {
    await Future.delayed(const Duration(seconds: 1));
    return '/mock/path/report.pdf';
  }

  @override
  Future<String> generateExcelReport(TimeFilter filter) async {
    await Future.delayed(const Duration(seconds: 1));
    return '/mock/path/report.xlsx';
  }

  double _getMultiplier(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.today:
        return 1.0;
      case TimeFilter.yesterday:
        return 1.1;
      case TimeFilter.last7Days:
        return 6.5;
      case TimeFilter.last30Days:
        return 28.0;
      case TimeFilter.thisMonth:
        return 15.0;
      case TimeFilter.custom:
        return 10.0;
    }
  }
}
