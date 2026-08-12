import 'package:flutter/foundation.dart';
import '../../../wagon/domain/entities/wagon.dart';
import '../../../truck/domain/entities/truck.dart';
import '../../../layer/domain/entities/layer.dart';

@immutable
class RegisterItemBalance {
  final String itemName;
  final int manifest;
  final int loaded;

  const RegisterItemBalance({
    required this.itemName,
    required this.manifest,
    required this.loaded,
  });

  int get remaining => manifest - loaded;
  double get completion => manifest == 0 ? 0 : loaded / manifest;
  bool get isValid => loaded >= 0 && loaded <= manifest;
}

@immutable
class DigitalRegister {
  final String id;
  final String wagonId;
  final String wagonNumber;
  final String origin;
  final String destination;
  final DateTime loadingDate;
  final String supervisor;
  final String? remarks;
  final WagonStatus status;
  final int totalTrucks;
  final int totalLayers;
  final int totalCartons;
  final int totalDefects;
  final Duration loadingDuration;
  final DateTime generatedAt;
  final DateTime lastOpenedAt;
  final int exportCount;
  final List<Truck> trucks;
  final List<RegisterItemBalance> itemBalances;
  final Map<String, List<LayerRecord>> layersByTruck;

  const DigitalRegister({
    required this.id,
    required this.wagonId,
    required this.wagonNumber,
    required this.origin,
    required this.destination,
    required this.loadingDate,
    this.supervisor = 'Not provided',
    this.remarks,
    required this.status,
    required this.totalTrucks,
    required this.totalLayers,
    required this.totalCartons,
    required this.totalDefects,
    required this.loadingDuration,
    required this.generatedAt,
    required this.lastOpenedAt,
    this.exportCount = 0,
    required this.trucks,
    this.itemBalances = const [],
    this.layersByTruck = const {},
  });

  int get manifestCartons =>
      itemBalances.fold(0, (sum, item) => sum + item.manifest);
  bool get hasManifest => itemBalances.isNotEmpty;
  int get remainingCartons =>
      itemBalances.fold(0, (sum, item) => sum + item.remaining);
  bool get isReconciled => reconciliationIssues.isEmpty;

  List<String> get reconciliationIssues {
    final issues = <String>[];
    if (itemBalances.any((item) => !item.isValid)) {
      issues.add('Loaded item quantities exceed the wagon manifest.');
    }
    final itemLoaded = itemBalances.fold(0, (sum, item) => sum + item.loaded);
    if (itemBalances.isNotEmpty && itemLoaded != totalCartons) {
      issues.add('Item totals do not match loaded cartons.');
    }
    for (final truck in trucks) {
      final layers = layersByTruck[truck.id] ?? const <LayerRecord>[];
      final cartons = layers.fold(0, (sum, layer) => sum + layer.cartonCount);
      final defects = layers.fold(0, (sum, layer) => sum + layer.defectCount);
      if (layers.length != truck.totalLayers ||
          cartons != truck.totalCartons ||
          defects != truck.totalDefects) {
        issues.add('Truck ${truck.truckNumber} does not match its layers.');
      }
      for (final layer in layers) {
        final allocated = layer.itemAllocations
            .fold(0, (sum, allocation) => sum + allocation.quantity);
        if (layer.itemAllocations.isNotEmpty &&
            allocated != layer.cartonCount) {
          issues.add(
              'Truck ${truck.truckNumber}, Layer ${layer.layerNumber} has an item mismatch.');
        }
      }
    }
    return issues;
  }

  DigitalRegister copyWith({
    String? id,
    String? wagonId,
    String? wagonNumber,
    String? origin,
    String? destination,
    DateTime? loadingDate,
    String? supervisor,
    String? remarks,
    WagonStatus? status,
    int? totalTrucks,
    int? totalLayers,
    int? totalCartons,
    int? totalDefects,
    Duration? loadingDuration,
    DateTime? generatedAt,
    DateTime? lastOpenedAt,
    int? exportCount,
    List<Truck>? trucks,
    List<RegisterItemBalance>? itemBalances,
    Map<String, List<LayerRecord>>? layersByTruck,
  }) {
    return DigitalRegister(
      id: id ?? this.id,
      wagonId: wagonId ?? this.wagonId,
      wagonNumber: wagonNumber ?? this.wagonNumber,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      loadingDate: loadingDate ?? this.loadingDate,
      supervisor: supervisor ?? this.supervisor,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      totalTrucks: totalTrucks ?? this.totalTrucks,
      totalLayers: totalLayers ?? this.totalLayers,
      totalCartons: totalCartons ?? this.totalCartons,
      totalDefects: totalDefects ?? this.totalDefects,
      loadingDuration: loadingDuration ?? this.loadingDuration,
      generatedAt: generatedAt ?? this.generatedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      exportCount: exportCount ?? this.exportCount,
      trucks: trucks ?? this.trucks,
      itemBalances: itemBalances ?? this.itemBalances,
      layersByTruck: layersByTruck ?? this.layersByTruck,
    );
  }
}
