abstract class CredentialStorage {
  /// Stores a user's password hash and salt securely.
  Future<void> storeCredentials(
      String employeeId, String hashedPassword, String salt);

  /// Retrieves the hashed password for an employee, or null if not found.
  Future<String?> getHashedPassword(String employeeId);

  /// Retrieves the cryptographic salt for an employee, or null if not found.
  Future<String?> getSalt(String employeeId);

  /// Removes a user's credentials securely.
  Future<void> removeCredentials(String employeeId);
}
