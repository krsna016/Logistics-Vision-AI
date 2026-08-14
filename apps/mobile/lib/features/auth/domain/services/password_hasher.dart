abstract class PasswordHasher {
  /// Hashes a plaintext password using a cryptographically secure algorithm.
  String hashPassword(String password, String salt);

  /// Hashes without blocking the UI isolate.
  Future<String> hashPasswordAsync(String password, String salt);

  /// Generates a random cryptographic salt.
  String generateSalt();

  /// Verifies if the plaintext password matches the hashed password.
  bool verifyPassword(String plaintext, String hashedPassword, String salt);

  /// Verifies without blocking the UI isolate.
  Future<bool> verifyPasswordAsync(
      String plaintext, String hashedPassword, String salt);
}
