import 'role.dart';

class AuditLog {
  final String id;
  final String userId;
  final String userName;
  final Role userRole;
  final String action;
  final DateTime timestamp;
  final String deviceName;
  final bool isSuccess;
  final String details;

  const AuditLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.action,
    required this.timestamp,
    required this.deviceName,
    required this.isSuccess,
    this.details = '',
  });
}
