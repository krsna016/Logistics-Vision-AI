import '../entities/user.dart';

abstract class AuthenticationService {
  Future<User?> login(String employeeId, String password, {bool offline = false});
  Future<void> logout();
}
