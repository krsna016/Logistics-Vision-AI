import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/device_session.dart';
import '../../domain/repositories/auth_repository.dart';

class RemoteAuthRepository implements AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  bool _locked = false;
  bool _sessionWasRevoked = false;
  String? _activeEmployeeId;
  User? _cachedUser;

  bool get sessionWasRevoked => _sessionWasRevoked;

  RemoteAuthRepository(this._dio, this._storage);

  @override
  Future<User?> login(String employeeId, String password,
      {bool offline = false}) async {
    try {
      final response = await _dio.post(
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
        await _storage.write(key: 'jwt_token', value: token);
        _activeEmployeeId = employeeId;
        _locked = false;
        return await getCurrentUser();
      }
      return null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    _activeEmployeeId = null;
    _locked = false;
    _sessionWasRevoked = false;
    _cachedUser = null;
  }

  @override
  Future<Session?> getCurrentSession() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || JwtDecoder.isExpired(token)) {
      await _storage.delete(key: 'jwt_token');
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
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || JwtDecoder.isExpired(token)) {
      await _storage.delete(key: 'jwt_token');
      _cachedUser = null;
      return null;
    }

    final decoded = JwtDecoder.decode(token);
    final employeeId = decoded['sub'];
    if (employeeId is! String) return null;

    try {
      final response = await _dio.get('/users/$employeeId');
      final data = response.data as Map<String, dynamic>;

      Role parseRole(String roleStr) {
        switch (roleStr.toLowerCase()) {
          case 'admin':
            return Role.administrator;
          case 'manager':
            return Role.manager;
          case 'supervisor':
            return Role.supervisor;
          case 'operator':
          default:
            return Role.operator;
        }
      }

      final user = User(
        id: data['id'] as String? ?? employeeId,
        employeeId: data['employee_id'] as String? ?? employeeId,
        name: data['name'] as String? ?? employeeId,
        role: parseRole(data['role'] as String? ?? 'Operator'),
        warehouse: 'warehouse_1',
        isActive: data['is_active'] as bool? ?? true,
      );
      _cachedUser = user;
      return user;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        _sessionWasRevoked = true;
        await _storage.delete(key: 'jwt_token');
        _cachedUser = null;
        return null;
      }
      return _cachedUser;
    } catch (_) {
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
      await _dio.post('/auth/login',
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
