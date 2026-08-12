import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/services/required_permission_policy.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  group('RequiredPermissionPolicy', () {
    test('accepts usable location permissions only', () {
      expect(
        RequiredPermissionPolicy.hasLocationAccess(
            LocationPermission.whileInUse),
        isTrue,
      );
      expect(
        RequiredPermissionPolicy.hasLocationAccess(LocationPermission.always),
        isTrue,
      );
      expect(
        RequiredPermissionPolicy.hasLocationAccess(LocationPermission.denied),
        isFalse,
      );
      expect(
        RequiredPermissionPolicy.hasLocationAccess(
            LocationPermission.deniedForever),
        isFalse,
      );
    });

    test('accepts granted and limited platform permissions', () {
      expect(
        RequiredPermissionPolicy.hasPlatformPermission(
            PermissionStatus.granted),
        isTrue,
      );
      expect(
        RequiredPermissionPolicy.hasPlatformPermission(
            PermissionStatus.limited),
        isTrue,
      );
      expect(
        RequiredPermissionPolicy.hasPlatformPermission(PermissionStatus.denied),
        isFalse,
      );
      expect(
        RequiredPermissionPolicy.hasPlatformPermission(
            PermissionStatus.permanentlyDenied),
        isFalse,
      );
    });
  });
}
