import '../entities/truck.dart';

abstract class TruckRepository {
  /// Get all active (non-soft-deleted) trucks.
  Future<List<Truck>> getActiveTrucks();

  /// Retrieve a specific truck by UUID.
  Future<Truck?> getTruckById(String id);

  /// Create a new truck record locally.
  Future<void> createTruck(Truck truck);

  /// Modify an existing truck record.
  Future<void> updateTruck(Truck truck);

  /// Perform a soft delete by marking isDeleted = true.
  Future<void> softDeleteTruck(String id);

  /// Archive an active truck, making it read-only.
  Future<void> archiveTruck(String id);

  /// Check if a truck number is already registered.
  Future<bool> isTruckNumberExists(String truckNumber, {String? excludeId});
}
