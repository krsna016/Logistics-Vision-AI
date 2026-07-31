abstract class SyncEngine {
  /// Starts the synchronization engine and begins listening for connectivity changes.
  Future<void> start();

  /// Pauses the engine (e.g., when the app goes into the background, if configured to stop).
  Future<void> pause();

  /// Forces a sync operation immediately, overriding normal batch delays.
  Future<void> forceSync();
}
