class DeviceSession {
  final String id;
  final String deviceName;
  final String deviceModel;
  final String osVersion;
  final DateTime lastSync;
  final bool isActive;

  const DeviceSession({
    required this.id,
    required this.deviceName,
    required this.deviceModel,
    required this.osVersion,
    required this.lastSync,
    this.isActive = true,
  });
}
