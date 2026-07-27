import '../entities/user.dart';
import '../entities/session.dart';
import '../entities/audit_log.dart';
import '../entities/device_session.dart';

abstract class AuthRepository {
  Future<User?> login(String employeeId, String password, {bool offline = false});
  Future<void> logout();
  Future<Session?> getCurrentSession();
  Future<User?> getCurrentUser();
  Future<void> lockSession();
  Future<bool> unlockSession(String pinOrPassword);
  Future<void> logAction(String action, {bool isSuccess = true, String details = ''});
  Future<List<AuditLog>> getAuditLogs();
  
  // Admin Management Methods
  Future<List<User>> getAllUsers();
  Future<void> createUser(User user);
  Future<void> toggleUserStatus(String userId, bool isActive);
  Future<List<DeviceSession>> getRegisteredDevices();
  Future<void> revokeDevice(String deviceId);
}
