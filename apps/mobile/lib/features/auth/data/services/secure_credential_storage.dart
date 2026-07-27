import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/services/credential_storage.dart';

class SecureCredentialStorage implements CredentialStorage {
  final FlutterSecureStorage _storage;

  const SecureCredentialStorage(this._storage);

  @override
  Future<void> storeCredentials(String employeeId, String hashedPassword, String salt) async {
    await _storage.write(key: 'pwd_hash_$employeeId', value: hashedPassword);
    await _storage.write(key: 'pwd_salt_$employeeId', value: salt);
  }

  @override
  Future<String?> getHashedPassword(String employeeId) async {
    return await _storage.read(key: 'pwd_hash_$employeeId');
  }

  @override
  Future<String?> getSalt(String employeeId) async {
    return await _storage.read(key: 'pwd_salt_$employeeId');
  }

  @override
  Future<void> removeCredentials(String employeeId) async {
    await _storage.delete(key: 'pwd_hash_$employeeId');
    await _storage.delete(key: 'pwd_salt_$employeeId');
  }
}
