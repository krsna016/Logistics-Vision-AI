import '../../domain/entities/wagon.dart';

class WagonModel {
  static Wagon fromJson(Map<String, dynamic> json) {
    return Wagon(
      id: json['id'] as String,
      wagonNumber: json['wagonNumber'] as String,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      loadingDate: DateTime.parse(json['loadingDate'] as String),
      expectedTruckCount: json['expectedTruckCount'] as int? ?? 0,
      completedTruckCount: json['completedTruckCount'] as int? ?? 0,
      status: WagonStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String),
        orElse: () => WagonStatus.planning,
      ),
      remarks: json['remarks'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static Map<String, dynamic> toJson(Wagon wagon) {
    return {
      'id': wagon.id,
      'wagonNumber': wagon.wagonNumber,
      'origin': wagon.origin,
      'destination': wagon.destination,
      'loadingDate': wagon.loadingDate.toIso8601String(),
      'expectedTruckCount': wagon.expectedTruckCount,
      'completedTruckCount': wagon.completedTruckCount,
      'status': wagon.status.name,
      'remarks': wagon.remarks,
      'createdAt': wagon.createdAt.toIso8601String(),
      'updatedAt': wagon.updatedAt.toIso8601String(),
    };
  }
}
