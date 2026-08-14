import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
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
import '../../../../services/storage_service.dart';
import '../../../../services/network_service.dart';
import '../../../../services/location_tracking_service.dart';
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
  final dio = Dio(BaseOptions(baseUrl: Environment.current.apiBaseUrl));
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

final locationTrackingServiceProvider = Provider((ref) {
  return LocationTrackingService(NetworkService(
    secureStorage: ref.watch(secureStorageProvider),
  ));
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
    ref.watch(offlineAuthProvider),
    ref.watch(secureStorageProvider),
    ref.watch(locationTrackingServiceProvider),
  );
});

class AuthNotifier extends StateNotifier<User?> with WidgetsBindingObserver {
  final AuthRepository _repository;
  final OfflineAuthenticationImpl _offlineAuth;
  final FlutterSecureStorage _storage;
  final LocationTrackingService _locationTracking;
  static const _cachedUserKey = 'cached_authenticated_user';

  static const _offlineAccessPrefix = 'offline_access_valid_until_';
  static const _offlineAccessWindow = Duration(hours: 24);

  AuthNotifier(this._repository, this._offlineAuth, this._storage,
      this._locationTracking)
      : super(null) {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    final cachedUser = await _restoreCachedUser();
    if (cachedUser != null && state == null) state = cachedUser;
    final remoteUser = await _repository.getCurrentUser();
    if (_sessionWasRevoked) {
      await logout();
      return;
    }
    // Prevent overriding a demo login if it happened while we were fetching
    if (state != null) return;

    if (remoteUser == null && cachedUser == null) {
      // Location tracking is intentionally opt-in. Starting GPS before a
      // successful login wastes battery and creates an unnecessary request.
      return;
    }

    final user = remoteUser ?? cachedUser!;
    if (!user.isActive) {
      await logout(); // Kill switch triggered, clear token
    } else {
      state = user;
    }
  }

  Future<void> _cacheUser(User user) async {
    await _storage.write(
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
  }

  Future<User?> _restoreCachedUser() async {
    try {
      final encoded = await _storage.read(key: _cachedUserKey);
      if (encoded == null || encoded.isEmpty) return null;
      final data = jsonDecode(encoded) as Map<String, dynamic>;
      final roleName = data['role'] as String?;
      return User(
        id: data['id'] as String? ?? '',
        employeeId: data['employeeId'] as String? ?? '',
        name: data['name'] as String? ?? '',
        role: parseRole(roleName),
        warehouse: data['warehouse'] as String?,
        isActive: data['isActive'] as bool? ?? true,
      );
    } catch (_) {
      await _storage.delete(key: _cachedUserKey);
      return null;
    }
  }

  bool get _sessionWasRevoked {
    return _repository is RemoteAuthRepository &&
        (_repository).sessionWasRevoked;
  }

  String get loginErrorMessage {
    if (_repository is RemoteAuthRepository) {
      return (_repository).lastLoginErrorMessage ??
          'Sign-in failed for an unknown reason.';
    }
    return 'Sign-in failed.';
  }

  Future<bool> login(String employeeId, String password,
      {bool offline = false}) async {
    try {
      final normalizedEmployeeId = employeeId.trim().toUpperCase();
      User? user;
      var authenticatedOnline = false;
      if (offline) {
        user = await _authenticateOffline(normalizedEmployeeId, password);
      } else {
        user = await _repository.login(
          normalizedEmployeeId,
          password,
          offline: false,
        );
        authenticatedOnline = user != null;
        if (user == null &&
            _repository is RemoteAuthRepository &&
            (_repository).lastLoginFailedForConnectivity) {
          user = await _authenticateOffline(normalizedEmployeeId, password);
        }
      }
      if (user != null) {
        await _cacheUser(user);
        state = user;
        if (authenticatedOnline) {
          // Offline access is useful but it should not keep a successfully
          // authenticated operator on the login screen.
          unawaited(_provisionOfflineAccess(user, password));
        }
        return true;
      }
      state = null;
      return false;
    } catch (error, stack) {
      AppLogger.error('Login processing failed', error, stack);
      return false;
    }
  }

  Future<void> _provisionOfflineAccess(User user, String password) async {
    try {
      await _offlineAuth.registerUser(user, password);
      await _storage.write(
        key: '$_offlineAccessPrefix${user.employeeId.toUpperCase()}',
        value:
            DateTime.now().add(_offlineAccessWindow).toUtc().toIso8601String(),
      );
    } catch (error, stack) {
      AppLogger.error(
        'Could not prepare bounded offline access after login',
        error,
        stack,
      );
    }
  }

  Future<User?> _authenticateOffline(String employeeId, String password) async {
    final expiryValue =
        await _storage.read(key: '$_offlineAccessPrefix$employeeId');
    final expiry = DateTime.tryParse(expiryValue ?? '');
    if (expiry == null || !expiry.isAfter(DateTime.now().toUtc())) return null;
    return _offlineAuth.authenticate(employeeId, password);
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

  /// Explicit employee opt-in. It deliberately does not run on login or app
  /// launch and is stopped when the authenticated session ends.
  Future<bool> startLiveTracking() async {
    if (state == null) return false;
    return _locationTracking.start();
  }

  Future<void> stopLiveTracking() => _locationTracking.stop();

  @override
  // ignore: avoid_renaming_method_parameters
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) {
      // Local-first sessions do not perform focus-triggered network checks.
    } else if (lifecycleState == AppLifecycleState.inactive ||
        lifecycleState == AppLifecycleState.hidden ||
        lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.detached) {}
  }

  Future<void> logout() async {
    await _locationTracking.stop();
    await _repository.logout();
    await _storage.delete(key: _cachedUserKey);
    state = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_locationTracking.stop());
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
