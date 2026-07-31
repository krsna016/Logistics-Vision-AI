import '../../domain/entities/time_filter.dart';
import '../../domain/entities/analytics_summary.dart';
import '../../domain/entities/performance_metrics.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../../wagon/domain/repositories/wagon_repository.dart';
import '../../../truck/domain/repositories/truck_repository.dart';
import '../../../layer/domain/repositories/layer_repository.dart';
import '../../../truck/domain/entities/truck.dart';
import '../../../layer/domain/entities/layer.dart';

/// Real analytics repository that computes metrics from the actual
/// local SQLite data (wagons, trucks, layers) instead of returning
/// random mock numbers.
class LocalAnalyticsRepository implements AnalyticsRepository {
  final WagonRepository _wagonRepo;
  final TruckRepository _truckRepo;
  final LayerRepository _layerRepo;

  LocalAnalyticsRepository(this._wagonRepo, this._truckRepo, this._layerRepo);

  // ──────────────────────────────────────────
  // Helper: date-range cutoff for the chosen filter
  // ──────────────────────────────────────────
  DateTime _cutoff(TimeFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case TimeFilter.today:
        return DateTime(now.year, now.month, now.day);
      case TimeFilter.yesterday:
        return DateTime(now.year, now.month, now.day - 1);
      case TimeFilter.last7Days:
        return now.subtract(const Duration(days: 7));
      case TimeFilter.last30Days:
        return now.subtract(const Duration(days: 30));
      case TimeFilter.thisMonth:
        return DateTime(now.year, now.month, 1);
      case TimeFilter.custom:
        return now.subtract(const Duration(days: 90));
    }
  }

  // ──────────────────────────────────────────
  // Fetch all trucks & layers, then filter by date
  // ──────────────────────────────────────────
  Future<List<Truck>> _trucksInRange(TimeFilter filter) async {
    final trucks = await _truckRepo.getActiveTrucks();
    final cutoff = _cutoff(filter);
    return trucks.where((t) => t.createdDate.isAfter(cutoff)).toList();
  }

  Future<List<LayerRecord>> _allLayersForTrucks(List<Truck> trucks) async {
    final List<LayerRecord> all = [];
    for (final t in trucks) {
      final layers = await _layerRepo.getLayersByTruck(t.id);
      all.addAll(layers.where((l) => !l.isDeleted));
    }
    return all;
  }

  // ──────────────────────────────────────────
  // SUMMARY
  // ──────────────────────────────────────────
  @override
  Future<AnalyticsSummary> getSummary(TimeFilter filter) async {
    final wagons = await _wagonRepo.getActiveWagons();
    final cutoff = _cutoff(filter);
    final filteredWagons =
        wagons.where((w) => w.createdAt.isAfter(cutoff)).toList();

    final trucks = await _trucksInRange(filter);
    final layers = await _allLayersForTrucks(trucks);

    final totalCartons = layers.fold<int>(0, (sum, l) => sum + l.cartonCount);

    // Average confidence across all layers
    double avgConfidence = 0.0;
    if (layers.isNotEmpty) {
      avgConfidence =
          layers.fold<double>(0.0, (sum, l) => sum + l.averageConfidence) /
              layers.length;
    }

    // Average loading time (time between truck creation and completion)
    Duration avgLoadTime = Duration.zero;
    final completedTrucks =
        trucks.where((t) => t.completedDate != null).toList();
    if (completedTrucks.isNotEmpty) {
      final totalMs = completedTrucks.fold<int>(
        0,
        (sum, t) =>
            sum + t.completedDate!.difference(t.createdDate).inMilliseconds,
      );
      avgLoadTime = Duration(milliseconds: totalMs ~/ completedTrucks.length);
    }

    return AnalyticsSummary(
      totalWagons: filteredWagons.length,
      totalTrucks: trucks.length,
      totalLayers: layers.length,
      totalCartons: totalCartons,
      averageConfidence: avgConfidence,
      averageLoadingTime: avgLoadTime,
    );
  }

  // ──────────────────────────────────────────
  // AI PERFORMANCE
  // ──────────────────────────────────────────
  @override
  Future<AIPerformanceMetrics> getAIPerformance(TimeFilter filter) async {
    final trucks = await _trucksInRange(filter);
    final layers = await _allLayersForTrucks(trucks);

    double avgConfidence = 0.0;
    if (layers.isNotEmpty) {
      avgConfidence =
          layers.fold<double>(0.0, (sum, l) => sum + l.averageConfidence) /
              layers.length;
    }

    return AIPerformanceMetrics(
      averageConfidence: avgConfidence,
      inferenceTimeMs: 0.0, // Not tracked per-layer yet
      fps: 0.0,
      manualCorrections: 0,
      rejectedDetections: 0,
      retakeRate: 0.0,
      detectionSuccessRate: layers.isNotEmpty ? 1.0 : 0.0,
      activeModelVersion: layers.isNotEmpty ? layers.first.modelVersion : 'N/A',
    );
  }

  // ──────────────────────────────────────────
  // LOADING PERFORMANCE
  // ──────────────────────────────────────────
  @override
  Future<LoadingPerformanceMetrics> getLoadingPerformance(
      TimeFilter filter) async {
    final trucks = await _trucksInRange(filter);
    final layers = await _allLayersForTrucks(trucks);
    final totalCartons = layers.fold<int>(0, (sum, l) => sum + l.cartonCount);

    // Avg layers per truck
    double avgLayersPerTruck = 0;
    if (trucks.isNotEmpty) {
      avgLayersPerTruck = layers.length / trucks.length;
    }

    // Avg cartons per layer
    int avgCartonsPerLayer = 0;
    if (layers.isNotEmpty) {
      avgCartonsPerLayer = totalCartons ~/ layers.length;
    }

    // Avg truck completion time
    Duration avgTruckTime = Duration.zero;
    final completedTrucks =
        trucks.where((t) => t.completedDate != null).toList();
    if (completedTrucks.isNotEmpty) {
      final totalMs = completedTrucks.fold<int>(
        0,
        (sum, t) =>
            sum + t.completedDate!.difference(t.createdDate).inMilliseconds,
      );
      avgTruckTime = Duration(milliseconds: totalMs ~/ completedTrucks.length);
    }

    // Build hourly carton trend (24 hours)
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final hourlyTrend = List<double>.filled(24, 0.0);
    for (final l in layers) {
      if (l.timestamp.isAfter(todayStart)) {
        final hour = l.timestamp.hour;
        hourlyTrend[hour] += l.cartonCount.toDouble();
      }
    }

    // Cartons per hour (total cartons / hours elapsed today, min 1)
    final hoursElapsed = now.hour + 1;
    final cartonsPerHour =
        layers.isNotEmpty ? totalCartons / hoursElapsed : 0.0;

    return LoadingPerformanceMetrics(
      cartonsLoadedPerHour: cartonsPerHour,
      averageLayersPerTruck: avgLayersPerTruck,
      averageTruckCompletionTime: avgTruckTime,
      averageWagonCompletionTime:
          Duration.zero, // Requires deeper wagon tracking
      averageCartonsPerLayer: avgCartonsPerLayer,
      hourlyCartonTrend: hourlyTrend,
    );
  }

  // ──────────────────────────────────────────
  // DATASET HEALTH
  // ──────────────────────────────────────────
  @override
  Future<DatasetHealthMetrics> getDatasetHealth(TimeFilter filter) async {
    final trucks = await _trucksInRange(filter);
    final layers = await _allLayersForTrucks(trucks);

    // Build daily capture trend (last 7 days)
    final now = DateTime.now();
    final dailyTrend = List<double>.filled(7, 0.0);
    for (final l in layers) {
      final daysAgo = now.difference(l.timestamp).inDays;
      if (daysAgo >= 0 && daysAgo < 7) {
        dailyTrend[6 - daysAgo] += 1.0;
      }
    }

    // Count images (layers with photoPath)
    final withPhoto = layers
        .where((l) => l.photoPath != null && l.photoPath!.isNotEmpty)
        .length;

    return DatasetHealthMetrics(
      imagesCaptured: withPhoto,
      approvedImages: withPhoto, // All confirmed layers are approved
      rejectedImages: 0,
      exportedImages: 0,
      pendingReview: 0,
      storageUsedMB: 0.0, // Would need file-system scan
      blurPercentage: 0.0,
      lightingIssues: 0.0,
      dailyCaptureTrend: dailyTrend,
    );
  }

  // ──────────────────────────────────────────
  // PRODUCTIVITY
  // ──────────────────────────────────────────
  @override
  Future<ProductivityMetrics> getProductivityMetrics(TimeFilter filter) async {
    final trucks = await _trucksInRange(filter);
    final layers = await _allLayersForTrucks(trucks);
    final totalCartons = layers.fold<int>(0, (sum, l) => sum + l.cartonCount);

    // Days in range
    final now = DateTime.now();
    final cutoff = _cutoff(filter);
    final daysInRange = now.difference(cutoff).inDays.clamp(1, 365);

    final truckThroughput = trucks.length / daysInRange;

    // Avg session duration from completed trucks
    Duration avgSession = Duration.zero;
    final completedTrucks =
        trucks.where((t) => t.completedDate != null).toList();
    if (completedTrucks.isNotEmpty) {
      final totalMs = completedTrucks.fold<int>(
        0,
        (sum, t) =>
            sum + t.completedDate!.difference(t.createdDate).inMilliseconds,
      );
      avgSession = Duration(milliseconds: totalMs ~/ completedTrucks.length);
    }

    // Avg layers & cartons per hour
    final hoursWorked = (avgSession.inMinutes * completedTrucks.length / 60.0)
        .clamp(1.0, 100000.0);
    final avgLayersPerHour =
        layers.isNotEmpty ? layers.length / hoursWorked : 0.0;
    final avgCartonsPerHour =
        totalCartons > 0 ? totalCartons / hoursWorked : 0.0;

    // Operator performance score (simple: completed trucks / total trucks ratio)
    final opPerformance =
        trucks.isNotEmpty ? completedTrucks.length / trucks.length : 0.0;

    return ProductivityMetrics(
      averageOperatorPerformance: opPerformance,
      truckThroughput: truckThroughput,
      averageLayersPerHour: avgLayersPerHour,
      averageCartonsPerHour: avgCartonsPerHour,
      averageSessionDuration: avgSession,
    );
  }

  // ──────────────────────────────────────────
  // REPORTS (placeholder — real export is in reports feature)
  // ──────────────────────────────────────────
  @override
  Future<String> generatePdfReport(TimeFilter filter) async {
    return '';
  }

  @override
  Future<String> generateExcelReport(TimeFilter filter) async {
    return '';
  }
}
