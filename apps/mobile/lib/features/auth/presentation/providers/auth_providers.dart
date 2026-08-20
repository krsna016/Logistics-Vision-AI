import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

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
import '../../../../services/storage_service.dart';
import '../../../../utils/logger.dart';
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
  final dio = Dio(BaseOptions(
    baseUrl: Environment.current.apiBaseUrl,
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 20),
  ));
  final storage = ref.watch(secureStorageProvider);
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await storage.read(key: StorageService.keyJwtToken);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (error, handler) async {
      // Keep the token until the auth repository can classify the response.
      // Deleting it in a generic interceptor made a temporary/expired-token
      // response indistinguishable from an administrator revocation and
      // prevented the next startup from validating the cached session.
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
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(secureStorageProvider),
  );
});

class AuthNotifier extends StateNotifier<User?> with WidgetsBindingObserver {
  final AuthRepository _repository;
  final FlutterSecureStorage _storage;
  // The cached profile makes the user experience persistent. The server is
  // consulted only to validate account status, never to sync operational data.
  static const _cachedUserKey = 'cached_authenticated_user';

  AuthNotifier(this._repository, this._storage) : super(null) {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    final cachedUser = await _restoreTrustedUser();
    if (cachedUser == null || state != null) return;

    if (_repository case final RemoteAuthRepository remoteRepository) {
      // A cached profile is display data, not authentication. Only restore it
      // while the independently stored, signed session token is still valid.
      if (!await remoteRepository.hasValidToken()) {
        await _storage.delete(key: _cachedUserKey);
        return;
      }
    }

    state = cachedUser;
    unawaited(_validateCachedAccount(cachedUser));
  }

  Future<void> _cacheTrustedUser(User user) => _storage.write(
        key: _cachedUserKey,
        value: jsonEncode({
          'id': user.id,
          'employeeId': user.employeeId,
          'name': user.name,
          'role': user.role.name,
          'warehouse': user.warehouse,
          'isActive': user.isActive,
        }),
      );

  Future<User?> _restoreTrustedUser() async {
    try {
      final encoded = await _storage.read(key: _cachedUserKey);
      if (encoded == null || encoded.isEmpty) return null;
      final data = jsonDecode(encoded) as Map<String, dynamic>;
      final employeeId = data['employeeId'] as String?;
      if (employeeId == null || employeeId.trim().isEmpty) {
        await _storage.delete(key: _cachedUserKey);
        return null;
      }
      return User(
        id: data['id'] as String? ?? employeeId,
        employeeId: employeeId,
        name: data['name'] as String? ?? employeeId,
        role: parseRole(data['role'] as String?),
        warehouse: data['warehouse'] as String?,
        isActive: data['isActive'] as bool? ?? true,
      );
    } catch (_) {
      await _storage.delete(key: _cachedUserKey);
      return null;
    }
  }

  String get loginErrorMessage {
    if (_repository is RemoteAuthRepository) {
      return (_repository).lastLoginErrorMessage ??
          'Sign-in failed for an unknown reason.';
    }
    return 'Sign-in failed.';
  }

  Future<bool> login(String employeeId, String password) async {
    try {
      final normalizedEmployeeId = employeeId.trim().toUpperCase();
      final user = await _repository.login(
        normalizedEmployeeId,
        password,
        offline: false,
      );
      if (user != null) {
        await _cacheTrustedUser(user);
        state = user;
        return true;
      }
      state = null;
      return false;
    } catch (error, stack) {
      AppLogger.error('Login processing failed', error, stack);
      return false;
    }
  }

  Future<void> _validateCachedAccount(User cachedUser) async {
    if (_repository is! RemoteAuthRepository) return;
    final remoteRepository = _repository;
    if (!await remoteRepository.hasValidToken()) {
      if (state?.employeeId == cachedUser.employeeId) state = null;
      await _storage.delete(key: _cachedUserKey);
      return;
    }
    final validatedUser = await remoteRepository.getCurrentUser();
    if (validatedUser != null) {
      await _cacheTrustedUser(validatedUser);
      if (state?.employeeId == cachedUser.employeeId) state = validatedUser;
      return;
    }
    if (remoteRepository.sessionWasRevoked &&
        state?.employeeId == cachedUser.employeeId) {
      await _storage.delete(key: _cachedUserKey);
      state = null;
    }
  }

  /// Starts a non-persistent local session for device demonstrations. It never
  /// sends credentials, creates a token, or starts session polling/tracking.
  void enterDemo() {
    if (Environment.current == Environment.production) return;
    state = const User(
      id: 'local_demo_operator',
      employeeId: 'DEMO',
      name: 'Demo Operator',
      role: Role.supervisor,
      warehouse: 'Local Test Warehouse',
    );
  }

  @override
  // ignore: avoid_renaming_method_parameters
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) {
      final currentUser = state;
      if (currentUser != null) unawaited(_validateCachedAccount(currentUser));
    } else if (lifecycleState == AppLifecycleState.inactive ||
        lifecycleState == AppLifecycleState.hidden ||
        lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.detached) {}
  }

  Future<void> logout() async {
    await _repository.logout();
    await _storage.delete(key: _cachedUserKey);
    state = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
