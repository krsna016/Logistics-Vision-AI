import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/repositories_impl/remote_auth_repository.dart';
import 'package:mobile/services/storage_service.dart';

String _unsignedToken(Map<String, Object> claims) {
  String encode(Object value) =>
      base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
  return '${encode({'alg': 'none', 'typ': 'JWT'})}.${encode(claims)}.';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('an expired token cannot restore a cached authenticated session',
      () async {
    final expiredToken = _unsignedToken({
      'sub': 'EMP001',
      'exp': DateTime.now()
              .toUtc()
              .subtract(const Duration(minutes: 1))
              .millisecondsSinceEpoch ~/
          1000,
    });
    FlutterSecureStorage.setMockInitialValues({
      StorageService.keyJwtToken: expiredToken,
    });
    const storage = FlutterSecureStorage();
    final repository = RemoteAuthRepository(Dio(), storage);

    expect(await repository.hasValidToken(), isFalse);
    expect(await repository.getCurrentUser(), isNull);
    expect(repository.sessionWasRevoked, isTrue);
    expect(await storage.read(key: StorageService.keyJwtToken), isNull);
  });
}
