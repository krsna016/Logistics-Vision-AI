import 'package:flutter/foundation.dart';

enum TruckStatus {
  loading,
  completed,
  dispatched;
  
  String get displayName {
    switch (this) {
      case TruckStatus.loading:
        return 'Active Loading';
      case TruckStatus.completed:
        return 'Completed';
      case TruckStatus.dispatched:
        return 'Dispatched';
    }
  }
}

enum SyncStatus {
  pending,
  synced,
  failed,
}

@immutable
class Truck {
  final String id;
  final String truckNumber;
  final String vehicleNumber;
  final String driverName;
  final String? driverMobile;
  final String company;
  final String warehouse;
  final TruckStatus status;
  final DateTime createdDate;
  final DateTime updatedDate;
  final DateTime? completedDate;
  final int totalLayers;
  final int totalCartons;
  final int totalDefects;
  final String? notes;
  final String? wagonId;
  final SyncStatus syncStatus;
  final bool isDeleted;
  final bool isArchived;

  const Truck({
    required this.id,
    required this.truckNumber,
    required this.vehicleNumber,
    required this.driverName,
    this.driverMobile,
    required this.company,
    required this.warehouse,
    required this.status,
    required this.createdDate,
    required this.updatedDate,
    this.wagonId,
    this.completedDate,
    this.totalLayers = 0,
    this.totalCartons = 0,
    this.totalDefects = 0,
    this.notes,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
    this.isArchived = false,
  });

  Truck copyWith({
    String? id,
    String? truckNumber,
    String? vehicleNumber,
    String? driverName,
    String? driverMobile,
    String? company,
    String? warehouse,
    TruckStatus? status,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? wagonId,
    DateTime? completedDate,
    int? totalLayers,
    int? totalCartons,
    int? totalDefects,
    String? notes,
    SyncStatus? syncStatus,
    bool? isDeleted,
    bool? isArchived,
  }) {
    return Truck(
      id: id ?? this.id,
      truckNumber: truckNumber ?? this.truckNumber,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      driverName: driverName ?? this.driverName,
      driverMobile: driverMobile ?? this.driverMobile,
      company: company ?? this.company,
      warehouse: warehouse ?? this.warehouse,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      wagonId: wagonId ?? this.wagonId,
      completedDate: completedDate ?? this.completedDate,
      totalLayers: totalLayers ?? this.totalLayers,
      totalCartons: totalCartons ?? this.totalCartons,
      totalDefects: totalDefects ?? this.totalDefects,
      notes: notes ?? this.notes,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
