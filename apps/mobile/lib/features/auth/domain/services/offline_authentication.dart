import '../entities/user.dart';

abstract class OfflineAuthentication {
  /// Authenticates a user offline using local SQLite and Secure Storage.
  Future<User?> authenticate(String employeeId, String password);
  
  /// Registers a new user and securely stores their credentials.
  Future<void> registerUser(User user, String password);
  
  /// Changes an existing user's password.
  Future<bool> changePassword(String employeeId, String oldPassword, String newPassword);
}
