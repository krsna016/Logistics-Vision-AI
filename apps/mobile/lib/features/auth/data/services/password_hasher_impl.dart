import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../../domain/services/password_hasher.dart';

class PasswordHasherImpl implements PasswordHasher {
  final _random = Random.secure();

  @override
  String generateSalt([int length = 16]) {
    final values = List<int>.generate(length, (i) => _random.nextInt(256));
    return base64UrlEncode(values);
  }

  @override
  String hashPassword(String password, String salt) {
    // A production system might use argon2 or pbkdf2.
    // For this implementation, we use SHA-256 with the salt, which fulfills the offline requirements.
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  bool verifyPassword(String plaintext, String hashedPassword, String salt) {
    final computedHash = hashPassword(plaintext, salt);
    return computedHash == hashedPassword;
  }
}
