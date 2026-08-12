import 'package:flutter/services.dart';

abstract final class PermissionSettingsService {
  static const _channel = MethodChannel('com.example.mobile/permissions');

  static Future<void> openAppPermissions() async {
    try {
      await _channel.invokeMethod<bool>('openAppPermissions');
    } on PlatformException {
      // The native implementation already falls back to App info. Keep this
      // helper safe on platforms without the Android channel.
    }
  }
}
