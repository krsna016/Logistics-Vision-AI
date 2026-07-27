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

  const RemoteAuthRepository(this._dio, this._storage);

  @override
  Future<User?> login(String employeeId, String password, {bool offline = false}) async {
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

      final token = response.data['access_token'];
      if (token != null) {
        await _storage.write(key: 'jwt_token', value: token);
        return await getCurrentUser();
      }
      return null;
    } on DioException catch (e) {
      print('Login error: $e');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  @override
  Future<Session?> getCurrentSession() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || JwtDecoder.isExpired(token)) return null;
    
    final decoded = JwtDecoder.decode(token);
    return Session(
      sessionId: 'sess_$token',
      userId: decoded['sub'], // The employee ID is stored in 'sub'
      deviceName: 'device',
      loginTime: DateTime.now(),
      lastActivity: DateTime.now(),
      isLocked: false,
    );
  }

  @override
  Future<User?> getCurrentUser() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null || JwtDecoder.isExpired(token)) return null;

    final decoded = JwtDecoder.decode(token);
    final employeeId = decoded['sub'];
    
    try {
      final response = await _dio.get('/users/$employeeId');
      final data = response.data;
      
      Role parseRole(String roleStr) {
        switch(roleStr.toLowerCase()) {
          case 'admin': return Role.administrator;
          case 'manager': return Role.manager;
          case 'supervisor': return Role.supervisor;
          case 'operator':
          default: return Role.operator;
        }
      }

      return User(
        id: data['id'] ?? employeeId,
        employeeId: data['employee_id'] ?? employeeId,
        name: data['name'] ?? employeeId,
        role: parseRole(data['role'] ?? 'Operator'),
        warehouse: 'warehouse_1',
        isActive: data['is_active'] ?? true,
      );
    } catch (e) {
      print('Failed to fetch user data: $e');
      // Fallback if the user fetch fails but token is valid
      return User(
        id: employeeId,
        employeeId: employeeId,
        name: employeeId,
        role: Role.operator,
        warehouse: 'warehouse_1',
        isActive: true,
      );
    }
  }

  @override
  Future<void> lockSession() async {}

  @override
  Future<bool> unlockSession(String pinOrPassword) async => true;

  @override
  Future<void> logAction(String action, {bool isSuccess = true, String details = '', String? userId, String? userName, Role? userRole}) async {}

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
