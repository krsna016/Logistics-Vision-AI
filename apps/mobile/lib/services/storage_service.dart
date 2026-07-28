import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage;

  StorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<void> init() async {
    // Database initialization, key extraction, and connection bootstrap.
    // Encrypted SQLite via SQLCipher will load here.
  }

  // Secure Storage keys
  static const String keyJwtToken = 'jwt_auth_token';
  static const String keyUserRole = 'user_role_type';

  Future<String?> readSecureValue(String key) async {
    return _secureStorage.read(key: key);
  }

  Future<void> writeSecureValue(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<void> deleteSecureValue(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> clearCache() async {
    // Purge temporary files and older non-modified pictures
  }
}
