import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const databaseEncryptionKeyStorageKey = 'smartload_database_encryption_key_v1';
const _secureStorage = FlutterSecureStorage();

Future<String> loadOrCreateDatabaseEncryptionKey() async {
  final existing = await _secureStorage.read(
    key: databaseEncryptionKeyStorageKey,
  );
  if (existing != null && existing.isNotEmpty) return existing;

  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  final generated = base64UrlEncode(bytes).replaceAll('=', '');
  await _secureStorage.write(
    key: databaseEncryptionKeyStorageKey,
    value: generated,
  );
  return generated;
}

Future<String?> readDatabaseEncryptionKey() =>
    _secureStorage.read(key: databaseEncryptionKeyStorageKey);
