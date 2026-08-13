import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/database/app_database.dart' hide User;
import 'package:mobile/features/auth/data/services/offline_authentication_impl.dart';
import 'package:mobile/features/auth/domain/entities/role.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/services/credential_storage.dart';
import 'package:mobile/features/auth/domain/services/password_hasher.dart';

void main() {
  test('online provisioning enables normalized offline authentication',
      () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final credentials = _MemoryCredentials();
    final auth = OfflineAuthenticationImpl(
      database,
      credentials,
      const _DeterministicHasher(),
    );

    await auth.registerUser(
      const User(
        id: 'user-1',
        employeeId: 'op-105',
        name: 'Operator',
        role: Role.supervisor,
      ),
      'correct horse battery staple',
    );

    expect((await database.select(database.users).getSingle()).employeeId,
        'OP-105');
    expect(
      (await auth.authenticate(' op-105 ', 'correct horse battery staple'))
          ?.employeeId,
      'OP-105',
    );
    expect(await auth.authenticate('OP-105', 'wrong password'), isNull);
  });

  test('five failed offline attempts lock the cached account', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final auth = OfflineAuthenticationImpl(
      database,
      _MemoryCredentials(),
      const _DeterministicHasher(),
    );
    await auth.registerUser(
      const User(
        id: 'user-2',
        employeeId: 'OP-106',
        name: 'Operator',
        role: Role.supervisor,
      ),
      'correct password',
    );

    for (var attempt = 0; attempt < 5; attempt++) {
      expect(await auth.authenticate('OP-106', 'wrong'), isNull);
    }
    final stored = await database.select(database.users).getSingle();
    expect(stored.failedLoginAttempts, 5);
    expect(stored.lockedUntil, isNotNull);
    expect(
      () => auth.authenticate('OP-106', 'correct password'),
      throwsA(isA<Exception>()),
    );
  });
}

class _MemoryCredentials implements CredentialStorage {
  final Map<String, String> _hashes = {};
  final Map<String, String> _salts = {};

  @override
  Future<String?> getHashedPassword(String employeeId) async =>
      _hashes[employeeId];

  @override
  Future<String?> getSalt(String employeeId) async => _salts[employeeId];

  @override
  Future<void> removeCredentials(String employeeId) async {
    _hashes.remove(employeeId);
    _salts.remove(employeeId);
  }

  @override
  Future<void> storeCredentials(
    String employeeId,
    String hashedPassword,
    String salt,
  ) async {
    _hashes[employeeId] = hashedPassword;
    _salts[employeeId] = salt;
  }
}

class _DeterministicHasher implements PasswordHasher {
  const _DeterministicHasher();

  @override
  String generateSalt() => 'test-salt';

  @override
  String hashPassword(String password, String salt) => '$salt:$password';

  @override
  bool verifyPassword(String plaintext, String hashedPassword, String salt) =>
      hashPassword(plaintext, salt) == hashedPassword;
}
