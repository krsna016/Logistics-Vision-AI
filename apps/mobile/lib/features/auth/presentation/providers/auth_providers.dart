import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/device_session.dart';
import '../../../../config/environment.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories_impl/remote_auth_repository.dart';
import 'package:dio/dio.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/services/password_hasher_impl.dart';
import '../../data/services/secure_credential_storage.dart';
import '../../data/services/offline_authentication_impl.dart';
import '../../data/services/session_manager_impl.dart';
import '../../data/services/authentication_service_impl.dart';

final passwordHasherProvider = Provider((ref) => PasswordHasherImpl());

final credentialStorageProvider = Provider((ref) {
  const storage = FlutterSecureStorage();
  return const SecureCredentialStorage(storage);
});

final offlineAuthProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  final credStorage = ref.watch(credentialStorageProvider);
  final hasher = ref.watch(passwordHasherProvider);
  return OfflineAuthenticationImpl(db, credStorage, hasher);
});

final sessionManagerProvider = Provider((ref) => SessionManagerImpl());

final authServiceProvider = Provider((ref) {
  final offlineAuth = ref.watch(offlineAuthProvider);
  final sessionManager = ref.watch(sessionManagerProvider);
  return AuthenticationServiceImpl(offlineAuth, sessionManager);
});


final dioProvider = Provider((ref) {
  // Uses environment configuration to fetch the correct base URL
  // Development: Local IP | Production: Cloud URL (e.g., Render)
  final dio = Dio(BaseOptions(baseUrl: Environment.current.apiBaseUrl));
  final storage = ref.watch(secureStorageProvider);
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await storage.read(key: 'jwt_token');
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        await storage.delete(key: 'jwt_token');
      }
      handler.next(error);
    },
  ));
  return dio;
});

final secureStorageProvider = Provider((ref) {
  return const FlutterSecureStorage();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageProvider);
  return RemoteAuthRepository(dio, storage);
});

// Provides the currently active user, or null if logged out.
final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<User?> {
  final AuthRepository _repository;
  Timer? _pollingTimer;

  AuthNotifier(this._repository) : super(null) {
    _init();
  }

  Future<void> _init() async {
    final user = await _repository.getCurrentUser();
    
    // Prevent overriding a demo login if it happened while we were fetching
    if (state != null) return; 
    
    if (user != null && !user.isActive) {
      await logout(); // Kill switch triggered, clear token
    } else {
      state = user;
      _startPolling();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (state == null) {
        _pollingTimer?.cancel();
        return;
      }
      final updatedUser = await _repository.getCurrentUser();
      if (updatedUser == null) {
        await logout(); // Token expired or account was revoked server-side.
      } else if (!updatedUser.isActive) {
        await logout(); // Account was revoked on the dashboard.
      }
    });
  }

  Future<bool> login(String employeeId, String password, {bool offline = false}) async {
    try {
      final user = await _repository.login(employeeId, password, offline: offline);
      state = user;
      if (user != null) {
        _startPolling();
      }
      return user != null;
    } catch (_) {
      return false;
    }
  }



  Future<void> logout() async {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    await _repository.logout();
    state = null;
  }
  
  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

// Session provider to track if the session is locked or active
final sessionProvider = FutureProvider<Session?>((ref) async {
  // Rebuild session state if the auth state changes
  ref.watch(authProvider);
  final repo = ref.watch(authRepositoryProvider);
  return repo.getCurrentSession();
});

// Audit log provider for viewing recent actions
final auditLogsProvider = FutureProvider<List<AuditLog>>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.getAuditLogs();
});

// Admin Providers
final userListProvider = FutureProvider<List<User>>((ref) async {
  return ref.watch(authRepositoryProvider).getAllUsers();
});

final deviceListProvider = FutureProvider<List<DeviceSession>>((ref) async {
  return ref.watch(authRepositoryProvider).getRegisteredDevices();
});

final globalAuditProvider = FutureProvider<List<AuditLog>>((ref) async {
  return ref.watch(authRepositoryProvider).getAuditLogs();
});
