import '../entities/defect.dart';

abstract class DefectRepository {
  /// Save a detected cargo defect.
  Future<void> saveDefect(DefectRecord defect);

  /// Retrieve all defects linked to a specific layer.
  Future<List<DefectRecord>> getDefectsByLayer(String layerId);

  /// Retrieve all defects linked to a truck session.
  Future<List<DefectRecord>> getDefectsByTruck(String truckId);

  /// Confirm or dismiss (false positive override) a defect status.
  Future<void> verifyDefect(String id,
      {required bool confirmedByOperator, String? notes});
}
