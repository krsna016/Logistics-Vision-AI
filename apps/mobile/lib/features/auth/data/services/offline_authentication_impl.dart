import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart' hide User, AuditLog;
import '../../domain/entities/user.dart';
import '../../domain/entities/role.dart';
import '../../domain/services/offline_authentication.dart';
import '../../domain/services/credential_storage.dart';
import '../../domain/services/password_hasher.dart';

class OfflineAuthenticationImpl implements OfflineAuthentication {
  final AppDatabase _db;
  final CredentialStorage _credentialStorage;
  final PasswordHasher _passwordHasher;

  const OfflineAuthenticationImpl(
      this._db, this._credentialStorage, this._passwordHasher);

  @override
  Future<User?> authenticate(String employeeId, String password) async {
    final normalizedEmployeeId = employeeId.trim().toUpperCase();

    // 1. Fetch user from SQLite
    var userRecord = await (_db.select(_db.users)
          ..where((t) => t.employeeId.equals(normalizedEmployeeId)))
        .getSingleOrNull();

    if (userRecord == null) return null;

    final user = userRecord;

    if (!user.isActive) {
      throw Exception('Account is disabled.');
    }

    if (user.lockedUntil != null && user.lockedUntil!.isAfter(DateTime.now())) {
      throw Exception(
          'Account is temporarily locked due to too many failed attempts.');
    }

    // 2. Fetch credentials from Secure Storage
    final storedHash =
        await _credentialStorage.getHashedPassword(normalizedEmployeeId);
    final salt = await _credentialStorage.getSalt(normalizedEmployeeId);

    if (storedHash == null || salt == null) {
      return null;
    }

    // 3. Verify
    bool isValid = _passwordHasher.verifyPassword(password, storedHash, salt);

    if (!isValid) {
      // Increment failed attempts
      final newAttempts = user.failedLoginAttempts + 1;
      DateTime? lockedUntil;
      if (newAttempts >= 5) {
        lockedUntil = DateTime.now().add(const Duration(minutes: 15));
      }

      await (_db.update(_db.users)
            ..where((t) => t.employeeId.equals(normalizedEmployeeId)))
          .write(
        UsersCompanion(
          failedLoginAttempts: Value(newAttempts),
          lockedUntil: Value(lockedUntil),
        ),
      );
      return null;
    }

    // 4. Reset failed attempts on success
    if (user.failedLoginAttempts > 0 || user.lockedUntil != null) {
      await (_db.update(_db.users)
            ..where((t) => t.employeeId.equals(normalizedEmployeeId)))
          .write(
        const UsersCompanion(
          failedLoginAttempts: Value(0),
          lockedUntil: Value(null),
        ),
      );
    }

    return User(
      id: user.id,
      employeeId: user.employeeId,
      name: user.name,
      role: Role.values.firstWhere(
          (r) => r.toString().split('.').last == user.role,
          orElse: () => Role.operator),
      warehouse: user.warehouseId,
      isActive: user.isActive,
      failedLoginAttempts: 0,
      lockedUntil: null,
    );
  }

  @override
  Future<void> registerUser(User user, String password) async {
    // 1. Generate salt & hash
    final salt = _passwordHasher.generateSalt();
    final hash = _passwordHasher.hashPassword(password, salt);

    // 2. Store securely
    await _credentialStorage.storeCredentials(user.employeeId, hash, salt);

    // 3. Save to SQLite
    await _db.into(_db.users).insert(
          UsersCompanion.insert(
            id: user.id,
            employeeId: user.employeeId,
            name: user.name,
            role: user.role.name,
            warehouseId: Value(user.warehouse),
            isActive: const Value(true),
            failedLoginAttempts: const Value(0),
          ),
          mode: InsertMode.replace,
        );
  }

  @override
  Future<bool> changePassword(
      String employeeId, String oldPassword, String newPassword) async {
    // Verify old password first
    final user = await authenticate(employeeId, oldPassword);
    if (user == null) {
      return false; // Old password verification failed
    }

    final newSalt = _passwordHasher.generateSalt();
    final newHash = _passwordHasher.hashPassword(newPassword, newSalt);

    await _credentialStorage.storeCredentials(employeeId, newHash, newSalt);
    return true;
  }
}
