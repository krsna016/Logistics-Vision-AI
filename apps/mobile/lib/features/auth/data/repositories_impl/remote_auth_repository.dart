import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/device_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../services/storage_service.dart';

class RemoteAuthRepository implements AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  bool _locked = false;
  bool _sessionWasRevoked = false;
  bool _lastLoginFailedForConnectivity = false;
  String? _lastLoginErrorMessage;
  String? _activeEmployeeId;
  User? _cachedUser;

  bool get sessionWasRevoked => _sessionWasRevoked;
  bool get lastLoginFailedForConnectivity => _lastLoginFailedForConnectivity;
  String? get lastLoginErrorMessage => _lastLoginErrorMessage;

  String? _responseDetail(Response<dynamic>? response) {
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) return detail.trim();
    }
    return null;
  }

  String? _tokenValidationFailure(String token) {
    try {
      final claims = JwtDecoder.decode(token);
      final exp = claims['exp'];
      if (exp is! num) return 'it has no valid expiry claim';
      final expiry =
          DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000).toUtc();
      if (!expiry.isAfter(DateTime.now().toUtc())) {
        return 'it was already expired when received';
      }
      return null;
    } catch (error) {
      return 'it is not a valid JWT (${error.runtimeType})';
    }
  }

  bool _isTokenUsable(String token) => _tokenValidationFailure(token) == null;

  Future<bool> hasValidToken() async {
    final token = await _storage.read(key: StorageService.keyJwtToken);
    return token != null && token.isNotEmpty && _isTokenUsable(token);
  }

  RemoteAuthRepository(this._dio, this._storage);

  @override
  Future<User?> login(String employeeId, String password,
      {bool offline = false}) async {
    _lastLoginFailedForConnectivity = false;
    _lastLoginErrorMessage = null;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'grant_type': 'password',
          'username': employeeId,
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final responseData = response.data as Map<String, dynamic>;
      final token = responseData['access_token'] as String?;
      if (token != null) {
        final tokenFailure = _tokenValidationFailure(token);
        if (tokenFailure != null) {
          _lastLoginErrorMessage =
              'The server accepted your credentials but issued an unusable session token: $tokenFailure.';
          return null;
        }
        await _storage.write(key: StorageService.keyJwtToken, value: token);
        _activeEmployeeId = employeeId;
        _locked = false;
        final user = await getCurrentUser();
        if (user == null) {
          _lastLoginErrorMessage ??=
              'Credentials were accepted, but the server rejected the new session. Contact an administrator.';
        }
        return user;
      }
      _lastLoginErrorMessage =
          'The server response did not contain a sign-in token.';
      return null;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      _lastLoginFailedForConnectivity =
          error.response == null || status == null || status >= 500;
      _lastLoginErrorMessage = switch (status) {
        400 => _responseDetail(error.response) ?? 'This account is inactive.',
        401 => _responseDetail(error.response) ??
            'The server rejected the employee ID or password.',
        403 => 'This account is not permitted to use the mobile app.',
        429 => _responseDetail(error.response) ??
            'The account is temporarily locked. Try again in 15 minutes.',
        int value when value >= 500 =>
          'The sign-in server is temporarily unavailable.',
        _ when error.response == null =>
          'Cannot reach the sign-in server. Check this phone’s internet connection.',
        _ => 'Sign-in failed with server response ${status ?? 'unknown'}.',
      };
      return null;
    } catch (error) {
      _lastLoginErrorMessage =
          'The sign-in response could not be processed (${error.runtimeType}).';
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: StorageService.keyJwtToken);
    _activeEmployeeId = null;
    _locked = false;
    _sessionWasRevoked = false;
    _cachedUser = null;
  }

  @override
  Future<Session?> getCurrentSession() async {
    final token = await _storage.read(key: StorageService.keyJwtToken);
    if (token == null || !_isTokenUsable(token)) {
      if (token != null) {
        final failure = _tokenValidationFailure(token);
        _lastLoginErrorMessage = failure == null
            ? null
            : 'The server-issued session token is unusable: $failure.';
      }
      _sessionWasRevoked =
          token != null && !_tokenValidationFailure(token)!.contains('expired');
      await _storage.delete(key: StorageService.keyJwtToken);
      _cachedUser = null;
      return null;
    }

    final decoded = JwtDecoder.decode(token);
    final employeeId = decoded['sub'];
    if (employeeId is! String) return null;
    return Session(
      sessionId: 'sess_$token',
      userId: employeeId,
      deviceName: 'device',
      loginTime: DateTime.now(),
      lastActivity: DateTime.now(),
      isLocked: _locked,
    );
  }

  @override
  Future<User?> getCurrentUser() async {
    _sessionWasRevoked = false;
    final token = await _storage.read(key: StorageService.keyJwtToken);
    if (token == null || !_isTokenUsable(token)) {
      _sessionWasRevoked =
          token != null && !_tokenValidationFailure(token)!.contains('expired');
      await _storage.delete(key: StorageService.keyJwtToken);
      _cachedUser = null;
      return null;
    }

    final decoded = JwtDecoder.decode(token);
    final employeeId = decoded['sub'];
    if (employeeId is! String) return null;

    try {
      final response =
          await _dio.get<Map<String, dynamic>>('/users/$employeeId');
      final data = response.data as Map<String, dynamic>;

      final user = User(
        id: data['id'] as String? ?? employeeId,
        employeeId: data['employee_id'] as String? ?? employeeId,
        name: data['name'] as String? ?? employeeId,
        role: parseRole(data['role'] as String?),
        warehouse: 'warehouse_1',
        isActive: data['is_active'] as bool? ?? true,
      );
      _cachedUser = user;
      return user;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      _lastLoginErrorMessage = switch (status) {
        401 => 'The server rejected the newly issued session token.',
        403 => 'The signed-in account cannot access its employee profile.',
        404 => 'The signed-in employee profile no longer exists.',
        _ => _responseDetail(error.response),
      };
      if (status == 401 || status == 403) {
        _sessionWasRevoked = true;
        await _storage.delete(key: StorageService.keyJwtToken);
        _cachedUser = null;
        return null;
      }
      return _cachedUser;
    } catch (error) {
      _lastLoginErrorMessage =
          'The server accepted your credentials, but its employee profile response could not be processed (${error.runtimeType}).';
      return _cachedUser;
    }
  }

  @override
  Future<void> lockSession() async {
    _locked = true;
  }

  @override
  Future<bool> unlockSession(String pinOrPassword) async {
    final employeeId = _activeEmployeeId;
    if (employeeId == null) return false;
    try {
      await _dio.post<Map<String, dynamic>>('/auth/login',
          data: {
            'grant_type': 'password',
            'username': employeeId,
            'password': pinOrPassword,
          },
          options: Options(contentType: Headers.formUrlEncodedContentType));
      _locked = false;
      return true;
    } on DioException {
      return false;
    }
  }

  @override
  Future<void> logAction(String action,
      {bool isSuccess = true,
      String details = '',
      String? userId,
      String? userName,
      Role? userRole}) async {}

  @override
  Future<List<AuditLog>> getAuditLogs() async => [];

  @override
  Future<List<User>> getAllUsers() async => [];

  @override
  Future<void> createUser(User user) async {}

  @override
  Future<void> toggleUserStatus(String userId, bool isActive) async {}

  @override
  Future<List<DeviceSession>> getRegisteredDevices() async => [];

  @override
  Future<void> revokeDevice(String deviceId) async {}
}
