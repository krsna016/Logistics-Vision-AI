import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../../domain/services/password_hasher.dart';

class PasswordHasherImpl implements PasswordHasher {
  final _random = Random.secure();
  static const _iterations = 120000;

  @override
  String generateSalt([int length = 16]) {
    final values = List<int>.generate(length, (i) => _random.nextInt(256));
    return base64UrlEncode(values);
  }

  @override
  String hashPassword(String password, String salt) =>
      _derivePasswordHash(password, salt);

  @override
  Future<String> hashPasswordAsync(String password, String salt) =>
      Isolate.run(() => _derivePasswordHash(password, salt));

  static String _derivePasswordHash(String password, String salt) {
    final saltBytes = utf8.encode(salt);
    final block = <int>[...saltBytes, 0, 0, 0, 1];
    final hmac = Hmac(sha256, utf8.encode(password));
    var u = hmac.convert(block).bytes;
    final derived = List<int>.from(u);
    for (var i = 1; i < _iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < derived.length; j++) {
        derived[j] ^= u[j];
      }
    }
    return 'pbkdf2-sha256\$$_iterations\$${base64UrlEncode(derived)}';
  }

  @override
  bool verifyPassword(String plaintext, String hashedPassword, String salt) {
    final computedHash = hashPassword(plaintext, salt);
    if (computedHash.length != hashedPassword.length) return false;
    var different = 0;
    for (var i = 0; i < computedHash.length; i++) {
      different |= computedHash.codeUnitAt(i) ^ hashedPassword.codeUnitAt(i);
    }
    return different == 0;
  }

  @override
  Future<bool> verifyPasswordAsync(
          String plaintext, String hashedPassword, String salt) =>
      Isolate.run(() {
        final computedHash = _derivePasswordHash(plaintext, salt);
        if (computedHash.length != hashedPassword.length) return false;
        var different = 0;
        for (var i = 0; i < computedHash.length; i++) {
          different |=
              computedHash.codeUnitAt(i) ^ hashedPassword.codeUnitAt(i);
        }
        return different == 0;
      });
}
