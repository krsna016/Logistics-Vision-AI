import '../entities/layer.dart';

abstract class LayerRepository {
  /// Save a completed layer to local database.
  Future<void> saveLayer(LayerRecord layer);

  /// Retrieve all layers for a specific truck.
  Future<List<LayerRecord>> getLayersByTruck(String truckId);

  /// Update an existing layer record (e.g. notes or audit entries).
  Future<void> updateLayer(LayerRecord layer);

  /// Soft delete a layer record.
  Future<void> softDeleteLayer(String id);

  /// Verify if a layer number is already taken inside a truck session.
  Future<bool> isLayerNumberExists(String truckId, int layerNumber);
  Future<void> clearAllData();
  Future<void> loadDemoData();
}
