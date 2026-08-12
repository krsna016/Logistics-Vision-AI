import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'network_service.dart';

/// Sends the signed-in device's latest position to the authenticated API.
/// The server derives employee identity from the JWT; it is never accepted
/// from the location payload.
class LocationTrackingService {
  final Dio _dio;
  StreamSubscription<Position>? _positionSubscription;
  Future<bool>? _pendingNotificationPermissionRequest;
  bool _running = false;
  bool _sending = false;

  LocationTrackingService(NetworkService network) : _dio = network.client;

  bool get isRunning => _running;

  /// Reads the current OS location permission without showing a prompt.
  Future<LocationPermission> checkPermission() {
    return Geolocator.checkPermission();
  }

  /// Requests the OS permission as soon as the app opens. The OS still
  /// requires the employee to approve the request; apps cannot grant this
  /// permission silently.
  Future<LocationPermission> requestPermission() async {
    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  /// Android requires the foreground-service notification to be visible for
  /// dependable background location. Ask for this separately from GPS access.
  Future<bool> requestNotificationPermission() {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return Future.value(true);
    }

    final pendingRequest = _pendingNotificationPermissionRequest;
    if (pendingRequest != null) return pendingRequest;

    return _requestNotificationPermission();
  }

  Future<bool> _requestNotificationPermission() async {
    final request = Permission.notification.request();
    _pendingNotificationPermissionRequest = request.then(
      (status) => status.isGranted || status.isLimited,
    );
    try {
      return await _pendingNotificationPermissionRequest!;
    } finally {
      _pendingNotificationPermissionRequest = null;
    }
  }

  Future<bool> start() async {
    if (_running) return true;
    final permission = await requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }
    if (!await requestNotificationPermission()) {
      // Do not claim background tracking is active if Android has blocked the
      // foreground-service notification that keeps it alive.
      return false;
    }

    _running = true;
    await _sendOnce();
    final LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Geolocator's Android foreground service keeps the stream alive when
      // the screen is locked or SmartLoad is minimized. Android displays this
      // ongoing notification as required for transparent background tracking.
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'SmartLoad live location is active',
          notificationText:
              'Your location is shared with authorized administrators while signed in.',
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // The iOS background mode and Always permission are declared in
      // Info.plist. Disabling automatic pausing keeps the tracking stream
      // active during normal background use.
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        activityType: ActivityType.otherNavigation,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      );
    }
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(_sendPosition, onError: (_, __) {});
    return true;
  }

  Future<void> stop() async {
    final wasRunning = _running;
    _running = false;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    if (!wasRunning) return;
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
