import '../../domain/entities/truck.dart';

class TruckModel {
  static Truck fromJson(Map<String, dynamic> json) {
    return Truck(
      id: json['id'] as String,
      truckNumber: json['truckNumber'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      driverName: json['driverName'] as String,
      driverMobile: json['driverMobile'] as String?,
      company: json['company'] as String,
      warehouse: json['warehouse'] as String,
      status: TruckStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String),
        orElse: () => TruckStatus.loading,
      ),
      createdDate: DateTime.parse(json['createdDate'] as String),
      updatedDate: DateTime.parse(json['updatedDate'] as String),
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      totalLayers: json['totalLayers'] as int? ?? 0,
      totalCartons: json['totalCartons'] as int? ?? 0,
      totalDefects: json['totalDefects'] as int? ?? 0,
      notes: json['notes'] as String?,
      wagonId: json['wagonId'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> toJson(Truck truck) {
    return {
      'id': truck.id,
      'truckNumber': truck.truckNumber,
      'vehicleNumber': truck.vehicleNumber,
      'driverName': truck.driverName,
      'driverMobile': truck.driverMobile,
      'company': truck.company,
      'warehouse': truck.warehouse,
      'status': truck.status.name,
      'createdDate': truck.createdDate.toIso8601String(),
      'updatedDate': truck.updatedDate.toIso8601String(),
      'completedDate': truck.completedDate?.toIso8601String(),
      'totalLayers': truck.totalLayers,
      'totalCartons': truck.totalCartons,
      'totalDefects': truck.totalDefects,
      'notes': truck.notes,
      'wagonId': truck.wagonId,
      'isDeleted': truck.isDeleted,
      'isArchived': truck.isArchived,
    };
  }
}
