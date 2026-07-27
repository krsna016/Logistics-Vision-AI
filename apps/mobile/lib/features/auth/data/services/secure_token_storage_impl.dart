import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/services/secure_token_storage.dart';

class SecureTokenStorageImpl implements SecureTokenStorage {
  final FlutterSecureStorage _storage;

  const SecureTokenStorageImpl(this._storage);

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  @override
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
