import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'network_service.dart';
import '../utils/logger.dart';

class LocationTrackingService {
  bool _running = false;

  LocationTrackingService(NetworkService network);

  bool get isRunning => _running;

  Future<LocationPermission> checkPermission() async => LocationPermission.denied;
  Future<LocationPermission> requestPermission() async => LocationPermission.denied;
  Future<bool> requestNotificationPermission() async => false;

  Future<bool> start() async {
    AppLogger.info('LocationTrackingService: Live GPS Tracking has been fully disabled per user configuration.');
    _running = false;
    return false;
  }

  Future<void> stop() async {
    _running = false;
  }
}
