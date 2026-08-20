import '../entities/user.dart';
import '../entities/session.dart';
import '../entities/audit_log.dart';
import '../entities/device_session.dart';

abstract class AuthRepository {
  Future<User?> login(String employeeId, String password,
      {bool offline = false});
  Future<void> logout();
  Future<Session?> getCurrentSession();
  Future<User?> getCurrentUser();
  Future<void> lockSession();
  Future<bool> unlockSession(String pinOrPassword);
  Future<void> logAction(String action,
      {bool isSuccess = true, String details = ''});
  Future<List<AuditLog>> getAuditLogs();

  // Admin Management Methods
  Future<List<User>> getAllUsers();

  /// Creates an account in the authority selected for this app build.
  /// The password is deliberately separate from [User] so it is never kept
  /// in a domain entity or written to local operational storage.
  Future<void> createUser(User user, {required String password});
  Future<void> toggleUserStatus(String employeeId, bool isActive);
  Future<List<DeviceSession>> getRegisteredDevices();
  Future<void> revokeDevice(String deviceId);
}
