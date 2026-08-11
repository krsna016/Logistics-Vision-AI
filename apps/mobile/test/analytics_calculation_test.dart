import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/analytics/data/repositories_impl/local_analytics_repository.dart';
import 'package:mobile/features/analytics/domain/entities/time_filter.dart';
import 'package:mobile/features/layer/domain/entities/layer.dart';
import 'package:mobile/features/layer/domain/repositories/layer_repository.dart';
import 'package:mobile/features/truck/domain/entities/truck.dart';
import 'package:mobile/features/truck/domain/repositories/truck_repository.dart';
import 'package:mobile/features/wagon/domain/entities/wagon.dart';
import 'package:mobile/features/wagon/domain/repositories/wagon_repository.dart';

void main() {
  test('yesterday excludes today and uses a 24-hour rate', () async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final truck = Truck(
      id: 'truck-1',
      truckNumber: 'vehicle-1',
      vehicleNumber: 'AS01AA0001',
      driverName: 'Driver',
      company: 'Carrier',
      warehouse: 'Warehouse',
      status: TruckStatus.completed,
      createdDate: yesterday.add(const Duration(hours: 8)),
      updatedDate: yesterday.add(const Duration(hours: 18)),
      completedDate: yesterday.add(const Duration(hours: 18)),
    );
    LayerRecord layer(String id, DateTime timestamp, int cartons) =>
        LayerRecord(
          id: id,
          truckId: truck.id,
          layerNumber: id == 'yesterday' ? 1 : 2,
          cartonCount: cartons,
          timestamp: timestamp,
          operatorId: 'Operator',
          modelVersion: 'manual',
          averageConfidence: 1,
          createdAt: timestamp,
          updatedAt: timestamp,
        );

    final repository = LocalAnalyticsRepository(
      _WagonRepo(),
      _TruckRepo([truck]),
      _LayerRepo({
        truck.id: [
          layer('yesterday', yesterday.add(const Duration(hours: 12)), 240),
          layer('today', today, 999),
        ],
      }),
    );

    final summary = await repository.getSummary(TimeFilter.yesterday);
    final performance =
        await repository.getLoadingPerformance(TimeFilter.yesterday);

    expect(summary.totalLayers, 1);
    expect(summary.totalCartons, 240);
    expect(performance.cartonsLoadedPerHour, 10);
    expect(performance.hourlyCartonTrend.reduce((a, b) => a + b), 240);
  });
}

class _WagonRepo implements WagonRepository {
  @override
  Future<List<Wagon>> getActiveWagons() async => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TruckRepo implements TruckRepository {
  final List<Truck> trucks;
  _TruckRepo(this.trucks);

  @override
  Future<List<Truck>> getActiveTrucks() async => trucks;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _LayerRepo implements LayerRepository {
  final Map<String, List<LayerRecord>> layers;
  _LayerRepo(this.layers);

  @override
  Future<List<LayerRecord>> getLayersByTruck(String truckId) async =>
      layers[truckId] ?? const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
