import '../../../../core/database/app_database.dart' as db;
import '../../domain/entities/analytics_snapshot.dart';
import '../../domain/entities/analytics_summary.dart';
import '../../domain/entities/performance_metrics.dart';
import '../../domain/entities/time_filter.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../../layer/domain/entities/layer.dart';
import '../../../layer/domain/repositories/layer_repository.dart';
import '../../../truck/domain/entities/truck.dart';
import '../../../truck/domain/repositories/truck_repository.dart';
import '../../../wagon/domain/repositories/wagon_repository.dart';

/// Computes every analytics card from one immutable data snapshot.
///
/// Production reads use three indexed bulk SQLite queries. Repository fallback
/// is retained for focused unit tests and non-SQLite implementations.
class LocalAnalyticsRepository implements AnalyticsRepository {
  final WagonRepository _wagonRepo;
  final TruckRepository _truckRepo;
  final LayerRepository _layerRepo;
  final db.AppDatabase? _database;

  LocalAnalyticsRepository(
    this._wagonRepo,
    this._truckRepo,
    this._layerRepo, {
    db.AppDatabase? database,
  }) : _database = database;

  ({DateTime start, DateTime end}) _range(TimeFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (filter) {
      case TimeFilter.today:
        return (start: today, end: now);
      case TimeFilter.yesterday:
        return (start: today.subtract(const Duration(days: 1)), end: today);
      case TimeFilter.last7Days:
        return (start: now.subtract(const Duration(days: 7)), end: now);
      case TimeFilter.last30Days:
        return (start: now.subtract(const Duration(days: 30)), end: now);
      case TimeFilter.thisMonth:
        return (start: DateTime(now.year, now.month, 1), end: now);
      case TimeFilter.custom:
        return (start: now.subtract(const Duration(days: 90)), end: now);
    }
  }

  bool _isInRange(DateTime value, ({DateTime start, DateTime end}) range) {
    return !value.isBefore(range.start) && value.isBefore(range.end);
  }

  Future<_AnalyticsData> _readData() async {
    final database = _database;
    if (database == null) {
      final wagons = await _wagonRepo.getActiveWagons();
      final trucks = await _truckRepo.getActiveTrucks();
      final groups = await Future.wait(
        trucks.map((truck) => _layerRepo.getLayersByTruck(truck.id)),
      );
      return _AnalyticsData(
        wagonCreatedAt: wagons.map((wagon) => wagon.createdAt).toList(),
        trucks: trucks,
        layers: groups.expand((layers) => layers).toList(),
      );
    }

    final results = await Future.wait<Object>([
      (database.select(database.wagons)
            ..where((wagon) => wagon.isDeleted.equals(false)))
          .get(),
      (database.select(database.trucks)
            ..where((truck) => truck.isDeleted.equals(false)))
          .get(),
      (database.select(database.layers)
            ..where((layer) => layer.isDeleted.equals(false)))
          .get(),
    ]);
    final wagons = results[0] as List<db.Wagon>;
    final trucks = results[1] as List<db.Truck>;
    final layers = results[2] as List<db.Layer>;
    return _AnalyticsData(
      wagonCreatedAt: wagons.map((wagon) => wagon.createdAt).toList(),
      trucks: trucks.map(_mapTruck).toList(),
      layers: layers.map(_mapLayer).toList(),
    );
  }

  Truck _mapTruck(db.Truck row) => Truck(
        id: row.id,
        truckNumber: row.truckNumber,
        vehicleNumber: row.vehicleNumber,
        driverName: row.driverName,
        driverMobile: row.driverMobile,
        company: row.company,
        warehouse: row.warehouse ?? '',
        status: TruckStatus.values.firstWhere(
          (status) => status.name == row.status,
          orElse: () => TruckStatus.loading,
        ),
        createdDate: row.createdAt,
        updatedDate: row.updatedAt,
        wagonId: row.wagonId,
        completedDate: row.completedDate,
        totalLayers: row.totalLayers,
        totalCartons: row.totalCartons,
        totalDefects: row.totalDefects,
        notes: row.notes,
        syncStatus: SyncStatus.values.firstWhere(
          (status) => status.name == row.syncStatus,
          orElse: () => SyncStatus.pending,
        ),
        isDeleted: row.isDeleted,
        isArchived: row.isArchived,
      );

  LayerRecord _mapLayer(db.Layer row) => LayerRecord(
        id: row.id,
        truckId: row.truckId,
        layerNumber: row.layerNumber,
        cartonCount: row.cartonCount,
        defectCount: row.defectCount,
        timestamp: row.timestamp ?? row.createdAt,
        operatorId: row.operatorId ?? 'local_operator',
        photoPath: row.photoPath,
        notes: row.notes,
        itemName: row.itemName,
        modelVersion: row.modelVersion ?? 'N/A',
        averageConfidence: row.averageConfidence,
        syncStatus: SyncStatus.values.firstWhere(
          (status) => status.name == row.syncStatus,
          orElse: () => SyncStatus.pending,
        ),
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        isDeleted: row.isDeleted,
      );

  @override
  Future<AnalyticsSnapshot> getSnapshot(TimeFilter filter) async {
    final range = _range(filter);
    final data = await _readData();
    final layersByTruck = <String, List<LayerRecord>>{};
    for (final layer in data.layers) {
      (layersByTruck[layer.truckId] ??= []).add(layer);
    }
    final trucks = data.trucks.where((truck) {
      final hasActivity = (layersByTruck[truck.id] ?? const <LayerRecord>[])
          .any((layer) => _isInRange(layer.timestamp, range));
      return _isInRange(truck.createdDate, range) ||
          hasActivity ||
          (truck.completedDate != null &&
              _isInRange(truck.completedDate!, range));
    }).toList();
    final truckIds = trucks.map((truck) => truck.id).toSet();
    final layers = data.layers
        .where((layer) =>
            truckIds.contains(layer.truckId) &&
            _isInRange(layer.timestamp, range))
        .toList();
    final totalCartons =
        layers.fold<int>(0, (sum, layer) => sum + layer.cartonCount);
    final averageConfidence = layers.isEmpty
        ? 0.0
        : layers.fold<double>(
                0, (sum, layer) => sum + layer.averageConfidence) /
            layers.length;
    final completedTrucks =
        trucks.where((truck) => truck.completedDate != null).toList();
    final averageCompletion = completedTrucks.isEmpty
        ? Duration.zero
        : Duration(
            milliseconds: completedTrucks.fold<int>(
                  0,
                  (sum, truck) =>
                      sum +
                      truck.completedDate!
                          .difference(truck.createdDate)
                          .inMilliseconds,
                ) ~/
                completedTrucks.length,
          );
    final hourlyTrend = List<double>.filled(24, 0);
    final dailyTrend = List<double>.filled(7, 0);
    final now = DateTime.now();
    for (final layer in layers) {
      hourlyTrend[layer.timestamp.hour] += layer.cartonCount;
      final daysAgo = now.difference(layer.timestamp).inDays;
      if (daysAgo >= 0 && daysAgo < 7) dailyTrend[6 - daysAgo] += 1;
    }
    final hoursElapsed =
        (range.end.difference(range.start).inMinutes / 60).clamp(1.0, 100000.0);
    final daysInRange =
        (range.end.difference(range.start).inHours / 24).ceil().clamp(1, 365);
    final hoursWorked =
        (averageCompletion.inMinutes * completedTrucks.length / 60.0)
            .clamp(1.0, 100000.0);
    final withPhoto =
        layers.where((layer) => layer.photoPath?.isNotEmpty == true).length;

    return AnalyticsSnapshot(
      summary: AnalyticsSummary(
        totalWagons:
            data.wagonCreatedAt.where((date) => _isInRange(date, range)).length,
        totalTrucks: trucks.length,
        totalLayers: layers.length,
        totalCartons: totalCartons,
        averageConfidence: averageConfidence,
        averageLoadingTime: averageCompletion,
      ),
      aiPerformance: AIPerformanceMetrics(
        averageConfidence: averageConfidence,
        detectionSuccessRate: layers.isEmpty ? 0 : 1,
        activeModelVersion: layers.isEmpty ? 'N/A' : layers.first.modelVersion,
      ),
      loadingPerformance: LoadingPerformanceMetrics(
        cartonsLoadedPerHour: layers.isEmpty ? 0 : totalCartons / hoursElapsed,
        averageLayersPerTruck:
            trucks.isEmpty ? 0 : layers.length / trucks.length,
        averageTruckCompletionTime: averageCompletion,
        averageCartonsPerLayer:
            layers.isEmpty ? 0 : totalCartons ~/ layers.length,
        hourlyCartonTrend: hourlyTrend,
      ),
      datasetHealth: DatasetHealthMetrics(
        imagesCaptured: withPhoto,
        approvedImages: withPhoto,
        dailyCaptureTrend: dailyTrend,
      ),
      productivity: ProductivityMetrics(
        averageOperatorPerformance:
            trucks.isEmpty ? 0 : completedTrucks.length / trucks.length,
        truckThroughput: trucks.length / daysInRange,
        averageLayersPerHour: layers.isEmpty ? 0 : layers.length / hoursWorked,
        averageCartonsPerHour:
            totalCartons == 0 ? 0 : totalCartons / hoursWorked,
        averageSessionDuration: averageCompletion,
      ),
    );
  }

  @override
  Future<AnalyticsSummary> getSummary(TimeFilter filter) async =>
      (await getSnapshot(filter)).summary;

  @override
  Future<AIPerformanceMetrics> getAIPerformance(TimeFilter filter) async =>
      (await getSnapshot(filter)).aiPerformance;

  @override
  Future<LoadingPerformanceMetrics> getLoadingPerformance(
          TimeFilter filter) async =>
      (await getSnapshot(filter)).loadingPerformance;

  @override
  Future<DatasetHealthMetrics> getDatasetHealth(TimeFilter filter) async =>
      (await getSnapshot(filter)).datasetHealth;

  @override
  Future<ProductivityMetrics> getProductivityMetrics(TimeFilter filter) async =>
      (await getSnapshot(filter)).productivity;

  @override
  Future<String> generatePdfReport(TimeFilter filter) async => '';

  @override
  Future<String> generateExcelReport(TimeFilter filter) async => '';
}

class _AnalyticsData {
  final List<DateTime> wagonCreatedAt;
  final List<Truck> trucks;
  final List<LayerRecord> layers;

  const _AnalyticsData({
    required this.wagonCreatedAt,
    required this.trucks,
    required this.layers,
  });
}
