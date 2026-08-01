import 'dart:async';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

import 'network_service.dart';

/// Sends the signed-in device's latest position to the authenticated API.
/// The server derives employee identity from the JWT; it is never accepted
/// from the location payload.
class LocationTrackingService {
  final Dio _dio;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _watchdog;
  bool _running = false;
  bool _sending = false;

  LocationTrackingService(NetworkService network) : _dio = network.client;

  bool get isRunning => _running;

  /// Requests the OS permission as soon as the app opens. The OS still
  /// requires the employee to approve the request; apps cannot grant this
  /// permission silently.
  Future<LocationPermission> requestPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationPermission.denied;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  Future<bool> start() async {
    if (_running) return true;
    final permission = await requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    _running = true;
    await _sendOnce();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen(_sendPosition, onError: (_, __) {});
    // This is a delivery watchdog, not dashboard polling: it keeps the
    // server's last-seen state fresh when GPS does not emit a movement event.
    _watchdog = Timer.periodic(const Duration(seconds: 30), (_) => _sendOnce());
    return true;
  }

  Future<void> stop() async {
    _running = false;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _watchdog?.cancel();
    _watchdog = null;
    try {
      await _dio.post<void>('/locations/stop');
    } on DioException {
      // The next session's heartbeat remains authoritative if offline.
    }
  }

  Future<void> _sendOnce() async {
    if (!_running) return;
    try {
      final position = await Geolocator.getCurrentPosition();
      await _sendPosition(position);
    } on DioException {
      // Network retry occurs on the next location update; no location is fabricated.
    } on TimeoutException {
      // GPS timeout is treated as a missing update.
    }
  }

  Future<void> _sendPosition(Position position) async {
    if (!_running || _sending) return;
    _sending = true;
    try {
      await _dio.post<void>('/locations/heartbeat', data: {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy_meters': position.accuracy,
        'recorded_at': DateTime.now().toUtc().toIso8601String(),
      });
    } on DioException {
      // Network retry occurs on the next location update; no location is fabricated.
    } finally {
      _sending = false;
    }
  }
}
