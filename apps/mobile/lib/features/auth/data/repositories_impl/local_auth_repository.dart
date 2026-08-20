import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart'
    hide User, AuditLog, DeviceSession;
import '../../../../utils/file_logger.dart' as import_file_logger;
import '../../domain/entities/user.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/device_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/services/authentication_service.dart';
import '../../domain/services/session_manager.dart';

class LocalAuthRepository implements AuthRepository {
  final AppDatabase _db;
  final AuthenticationService _authService;
  final SessionManager _sessionManager;

  const LocalAuthRepository(this._db, this._authService, this._sessionManager);

  @override
  Future<User?> login(String employeeId, String password,
      {bool offline = false}) async {
    final user =
        await _authService.login(employeeId, password, offline: offline);
    if (user != null) {
      await logAction('Login',
          details: offline ? 'Offline mode' : 'Online mode',
          userId: user.id,
          userName: user.name,
          userRole: user.role);
    } else {
      await logAction('Login Failed',
          isSuccess: false,
          details: 'Invalid credentials or locked account for $employeeId',
          userId: 'unknown',
          userName: 'Unknown',
          userRole: Role.supervisor);
    }
    return user;
  }

  @override
  Future<void> logout() async {
    final currentSession = _sessionManager.currentSession.value;
    if (currentSession != null) {
      final user = await getCurrentUser();
      await logAction('Logout',
          userId: user?.id, userName: user?.name, userRole: user?.role);
    }
    await _authService.logout();
  }

  @override
  Future<Session?> getCurrentSession() async =>
      _sessionManager.currentSession.value;

  @override
  Future<User?> getCurrentUser() async {
    final session = _sessionManager.currentSession.value;
    if (session == null) return null;

    final record = await (_db.select(_db.users)
          ..where((t) => t.id.equals(session.userId)))
        .getSingleOrNull();
    if (record == null) return null;

    return User(
      id: record.id,
      employeeId: record.employeeId,
      name: record.name,
      role: parseRole(record.role),
      warehouse: record.warehouseId,
      isActive: record.isActive,
      failedLoginAttempts: record.failedLoginAttempts,
      lockedUntil: record.lockedUntil,
    );
  }

  @override
  Future<void> lockSession() async {
    await _sessionManager.lockSession();
    final user = await getCurrentUser();
    await logAction('Session Locked',
        userId: user?.id, userName: user?.name, userRole: user?.role);
  }

  @override
  Future<bool> unlockSession(String pinOrPassword) async {
    final user = await getCurrentUser();
    if (user == null) return false;

    final authenticated =
        await _authService.login(user.employeeId, pinOrPassword, offline: true);
    final isValid = authenticated != null;

    if (isValid) {
      await _sessionManager.unlockSession();
      await logAction('Session Unlocked',
          userId: user.id, userName: user.name, userRole: user.role);
      return true;
    }

    await logAction('Session Unlock Failed',
        isSuccess: false,
        userId: user.id,
        userName: user.name,
        userRole: user.role);
    return false;
  }

  @override
  Future<void> logAction(String action,
      {bool isSuccess = true,
      String details = '',
      String? userId,
      String? userName,
      Role? userRole}) async {
    try {
      final String safeUserId = userId ?? 'guest';
      final String safeUserName = userName ?? 'Unknown';
      import_file_logger.FileLogger.setUserId(safeUserId);
      import_file_logger.FileLogger.log(
          'AUTH: $action | Success: $isSuccess | User: $safeUserName | Details: $details');
    } catch (_) {}
    final session = _sessionManager.currentSession.value;
    final uid = userId ?? session?.userId ?? 'guest';
    await _db.into(_db.auditLogs).insert(
          AuditLogsCompanion.insert(
            id: 'log_${DateTime.now().millisecondsSinceEpoch}',
            entityId: uid,
            entityType: 'User',
            action: action,
            userId: uid,
            details: Value(details),
            // Device name is tracked in session
          ),
        );
  }

  @override
  Future<List<AuditLog>> getAuditLogs() async {
    final records = await (_db.select(_db.auditLogs)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)
          ])
          ..limit(100))
        .get();

    return records
        .map((r) => AuditLog(
              id: r.id,
              userId: r.userId,
              userName:
                  'Unknown', // Would join with Users table in a real query
              userRole: Role.supervisor,
              action: r.action,
              timestamp: r.timestamp,
              deviceName: 'Device',
              isSuccess: !r.action.contains('Failed'),
              details: r.details ?? '',
            ))
        .toList();
  }

  @override
  Future<List<User>> getAllUsers() async {
    final records = await _db.select(_db.users).get();
    return records
        .map((r) => User(
              id: r.id,
              employeeId: r.employeeId,
              name: r.name,
              role: parseRole(r.role),
              warehouse: r.warehouseId,
              isActive: r.isActive,
              failedLoginAttempts: r.failedLoginAttempts,
              lockedUntil: r.lockedUntil,
            ))
        .toList();
  }

  @override
  Future<void> createUser(User user) async {
    await _db.into(_db.users).insert(
          UsersCompanion.insert(
            id: user.id,
            employeeId: user.employeeId,
            name: user.name,
            role: user.role.toString().split('.').last,
            warehouseId: Value(user.warehouse),
            isActive: Value(user.isActive),
            failedLoginAttempts: Value(user.failedLoginAttempts),
            lockedUntil: Value(user.lockedUntil),
          ),
          mode: InsertMode.replace,
        );
    final currentUser = await getCurrentUser();
    await logAction('Created User',
        details: 'Added ${user.employeeId}',
        userId: currentUser?.id,
        userName: currentUser?.name,
        userRole: currentUser?.role);
  }

  @override
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    await (_db.update(_db.users)..where((t) => t.id.equals(userId))).write(
      UsersCompanion(isActive: Value(isActive)),
    );
    final currentUser = await getCurrentUser();
    await logAction(isActive ? 'Enabled User' : 'Disabled User',
        details: 'User ID: $userId',
        userId: currentUser?.id,
        userName: currentUser?.name,
        userRole: currentUser?.role);
  }

  @override
  Future<List<DeviceSession>> getRegisteredDevices() async {
    final records = await _db.select(_db.deviceSessions).get();
    return records
        .map((r) => DeviceSession(
              id: r.id,
              deviceName: r.deviceName,
              deviceModel: r.deviceModel,
              osVersion: r.osVersion,
              isActive: r.isActive,
              lastActiveAt: r.lastActiveAt,
            ))
        .toList();
  }

  @override
  Future<void> revokeDevice(String deviceId) async {
    await (_db.update(_db.deviceSessions)..where((t) => t.id.equals(deviceId)))
        .write(
      const DeviceSessionsCompanion(isActive: Value(false)),
    );
    final currentUser = await getCurrentUser();
    await logAction('Revoked Device',
        details: 'Device ID: $deviceId',
        userId: currentUser?.id,
        userName: currentUser?.name,
        userRole: currentUser?.role);
  }
}
