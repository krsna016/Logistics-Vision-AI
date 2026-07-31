import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage;

  StorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<void> init() async {
    // Database initialization, key extraction, and connection bootstrap.
    // Authentication/session secrets are stored in platform secure storage.
    // The Drift database itself is currently app-private plain SQLite.
  }

  // Secure Storage keys
  // Keep the token key in one place so every HTTP client uses the same value.
  // Existing releases already persist the active token under this key.
  static const String keyJwtToken = 'jwt_token';
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
