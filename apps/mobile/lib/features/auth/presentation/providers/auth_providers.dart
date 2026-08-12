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
      if (error.response?.statusCode == 401) {
        await storage.delete(key: StorageService.keyJwtToken);
      }
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
    ref.watch(secureStorageProvider),
    ref.watch(locationTrackingServiceProvider),
  );
});

class AuthNotifier extends StateNotifier<User?> with WidgetsBindingObserver {
  final AuthRepository _repository;
  final FlutterSecureStorage _storage;
  final LocationTrackingService _locationTracking;
  Timer? _pollingTimer;
  bool _checkingCurrentUser = false;
  static const _cachedUserKey = 'cached_authenticated_user';
  static const _foregroundSessionCheckInterval = Duration(minutes: 2);

  AuthNotifier(this._repository, this._storage, this._locationTracking)
      : super(null) {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    final remoteUser = await _repository.getCurrentUser();
    if (_sessionWasRevoked) {
      await logout();
      return;
    }
    final canRestoreCachedSession = _repository is RemoteAuthRepository
        ? await (_repository).hasValidToken()
        : true;
    final user = remoteUser ??
        (canRestoreCachedSession ? await _restoreCachedUser() : null);

    // Prevent overriding a demo login if it happened while we were fetching
    if (state != null) return;

    if (user == null) {
      // Location tracking is intentionally opt-in. Starting GPS before a
      // successful login wastes battery and creates an unnecessary request.
      return;
    }

    if (!user.isActive) {
      await logout(); // Kill switch triggered, clear token
    } else {
      state = user;
      _startPolling();
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

  void _startPolling() {
    _pollingTimer?.cancel();
    if (state == null ||
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }
    _pollingTimer = Timer.periodic(_foregroundSessionCheckInterval, (_) {
      unawaited(_refreshCurrentUser());
    });
  }

  Future<void> _refreshCurrentUser() async {
    if (state == null || _checkingCurrentUser) return;
    _checkingCurrentUser = true;
    try {
      final updatedUser = await _repository.getCurrentUser();
      if (_sessionWasRevoked) {
        await logout(); // The server explicitly rejected or revoked access.
      } else if (updatedUser != null && !updatedUser.isActive) {
        await logout(); // Account was revoked on the dashboard.
      } else if (updatedUser != null) {
        await _cacheUser(updatedUser);
      }
    } finally {
      _checkingCurrentUser = false;
    }
  }

  Future<bool> login(String employeeId, String password,
      {bool offline = false}) async {
    try {
      final user =
          await _repository.login(employeeId, password, offline: offline);
      state = user;
      if (user != null) {
        await _cacheUser(user);
        _startPolling();
      }
      return user != null;
    } catch (_) {
      return false;
    }
  }

  /// Opt-in hook retained for a future administrator-controlled live-tracking
  /// control. It deliberately does not run on login or app launch.
  Future<bool> startLiveTracking() async {
    if (state == null) return false;
    return _locationTracking.start();
  }

  Future<void> stopLiveTracking() => _locationTracking.stop();

  @override
  // ignore: avoid_renaming_method_parameters
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) {
      unawaited(_refreshCurrentUser());
      _startPolling();
    } else if (lifecycleState == AppLifecycleState.inactive ||
        lifecycleState == AppLifecycleState.hidden ||
        lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.detached) {
      _pollingTimer?.cancel();
      _pollingTimer = null;
    }
  }

  Future<void> logout() async {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    await _locationTracking.stop();
    await _repository.logout();
    await _storage.delete(key: _cachedUserKey);
    state = null;
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
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
