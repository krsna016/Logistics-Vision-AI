import '../entities/loading_session.dart';

abstract class LoadingSessionRepository {
  /// Save or update a loading session.
  Future<void> saveSession(LoadingSession session);

  /// Retrieve a loading session by UUID.
  Future<LoadingSession?> getSessionById(String id);

  /// Retrieve the active loading session for a truck, if one exists.
  Future<LoadingSession?> getActiveSessionForTruck(String truckId);

  /// Retrieve all sessions for a specific warehouse.
  Future<List<LoadingSession>> getSessionsByWarehouse(String warehouseId);

  /// Auto-recovers the last unclosed loading session on application boot.
  Future<LoadingSession?> recoverLastActiveSession();
}
