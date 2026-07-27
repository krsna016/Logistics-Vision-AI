import '../../domain/entities/user.dart';
import '../../domain/services/authentication_service.dart';
import '../../domain/services/offline_authentication.dart';
import '../../domain/services/session_manager.dart';

class AuthenticationServiceImpl implements AuthenticationService {
  final OfflineAuthentication _offlineAuth;
  final SessionManager _sessionManager;

  const AuthenticationServiceImpl(this._offlineAuth, this._sessionManager);

  @override
  Future<User?> login(String employeeId, String password, {bool offline = false}) async {
    // For Vinayak SmartLoad offline-first architecture, all logins are validated locally first.
    final user = await _offlineAuth.authenticate(employeeId, password);
    
    if (user != null) {
      await _sessionManager.startSession(user);
    }
    
    return user;
  }

  @override
  Future<void> logout() async {
    await _sessionManager.endSession();
  }
}
