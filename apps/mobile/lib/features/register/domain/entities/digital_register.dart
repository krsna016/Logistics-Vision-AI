import 'package:flutter/foundation.dart';
import '../../../wagon/domain/entities/wagon.dart';
import '../../../truck/domain/entities/truck.dart';

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

  const DigitalRegister({
    required this.id,
    required this.wagonId,
    required this.wagonNumber,
    required this.origin,
    required this.destination,
    required this.loadingDate,
    this.supervisor = 'Operations Supervisor',
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
  });

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
    );
  }
}
