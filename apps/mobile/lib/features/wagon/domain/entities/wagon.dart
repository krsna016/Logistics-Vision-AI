import 'package:flutter/foundation.dart';

enum WagonStatus {
  planning,
  loading,
  completed,
  archived;

  String get displayName {
    switch (this) {
      case WagonStatus.planning:
        return 'Planning';
      case WagonStatus.loading:
        return 'Loading';
      case WagonStatus.completed:
        return 'Completed';
      case WagonStatus.archived:
        return 'Archived';
    }
  }
}

@immutable
class Wagon {
  final String id;
  final String wagonNumber;
  final String origin;
  final String destination;
  final DateTime loadingDate;
  final int expectedTruckCount;
  final int completedTruckCount;
  final WagonStatus status;
  final String? remarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Wagon({
    required this.id,
    required this.wagonNumber,
    required this.origin,
    required this.destination,
    required this.loadingDate,
    required this.expectedTruckCount,
    required this.completedTruckCount,
    required this.status,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
  });

  Wagon copyWith({
    String? id,
    String? wagonNumber,
    String? origin,
    String? destination,
    DateTime? loadingDate,
    int? expectedTruckCount,
    int? completedTruckCount,
    WagonStatus? status,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wagon(
      id: id ?? this.id,
      wagonNumber: wagonNumber ?? this.wagonNumber,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      loadingDate: loadingDate ?? this.loadingDate,
      expectedTruckCount: expectedTruckCount ?? this.expectedTruckCount,
      completedTruckCount: completedTruckCount ?? this.completedTruckCount,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
