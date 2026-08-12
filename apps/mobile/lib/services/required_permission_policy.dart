import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Defines which permission states permit SmartLoad operational workflows.
abstract final class RequiredPermissionPolicy {
  static bool hasLocationAccess(LocationPermission permission) {
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  static bool hasPlatformPermission(PermissionStatus status) {
    return status.isGranted || status.isLimited;
  }
}
