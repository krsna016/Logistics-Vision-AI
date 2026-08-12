import 'package:flutter/foundation.dart';

@immutable
class WagonItem {
  final String name;
  final int quantity;

  const WagonItem({required this.name, required this.quantity});

  Map<String, dynamic> toJson() => {'name': name, 'quantity': quantity};

  factory WagonItem.fromJson(Map<String, dynamic> json) => WagonItem(
        name: (json['name'] as String? ?? '').trim(),
        quantity: (json['quantity'] as num? ?? 0).toInt(),
      );
}

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
  final List<WagonItem> items;
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
    this.items = const [],
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
    List<WagonItem>? items,
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
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// A wagon without an item manifest does not require item reconciliation.
  /// When a manifest exists, every declared item must be loaded exactly.
  bool isManifestReconciled(Map<String, int> loadedByItem) {
    return items.isEmpty ||
        items.every((item) => loadedByItem[item.name] == item.quantity);
  }
}
