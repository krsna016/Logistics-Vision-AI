import 'dart:async';

abstract class ConnectivityService {
  /// Stream of network availability status.
  Stream<bool> get isConnectedStream;

  /// Check current internet reachability (not just WiFi connection, but actual internet access).
  Future<bool> hasInternetAccess();
}
