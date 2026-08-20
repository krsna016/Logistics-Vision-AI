import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/camera/presentation/screens/count_method_screens.dart';
import '../features/camera/presentation/screens/capture_workspace_screen.dart';

import '../features/truck/presentation/screens/truck_details_screen.dart';
import '../features/truck/domain/entities/truck.dart';
import '../features/layer/presentation/screens/layer_review_screen.dart';
import '../features/layer/domain/entities/ai_result.dart';
import '../features/layer/domain/entities/layer.dart';
import '../core/ai_engine/models/ai_model.dart';

import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/wagon/presentation/screens/wagon_list_screen.dart';
import '../features/wagon/presentation/screens/wagon_details_screen.dart';

import '../features/register/presentation/screens/register_list_screen.dart';
import '../features/register/presentation/screens/register_details_screen.dart';
import '../core/presentation/screens/user_manual_screen.dart';
import '../core/presentation/screens/legal_privacy_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/auth/domain/entities/user.dart';
import '../features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import '../features/settings/presentation/screens/ai_camera_settings_screen.dart';
import '../features/auth/presentation/screens/profile_screen.dart';
import '../features/auth/presentation/screens/admin_security_screen.dart';
import '../features/auth/presentation/screens/user_management_screen.dart';
import '../features/auth/presentation/screens/role_policies_screen.dart';

import '../core/presentation/widgets/root_back_guard.dart';
import '../utils/file_logger.dart';

class AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      FileLogger.log(
          'NAVIGATED TO: ${route.settings.name} (${route.settings.arguments ?? ""})');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute?.settings.name != null) {
      FileLogger.log('RETURNED TO: ${previousRoute!.settings.name}');
    }
  }
}

// Router provider representing Riverpod-based dependency injection for GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  // Keep one stable router during startup. Refresh route guards from auth
  // changes without recreating GoRouter and resetting the initial route.
  final authRefresh = _AuthRouterRefresh(ref);
  return GoRouter(
    initialLocation: '/', // default to splash
    refreshListenable: authRefresh,
    observers: [AppRouteObserver()],
    redirect: (context, state) {
      final user = ref.read(authProvider);
      final isLoggingIn = state.uri.toString() == '/login';
      final isSplash = state.uri.toString() == '/';

      // Kill-switch: If user is deactivated on the backend, force them to login
      if (user != null && !user.isActive) {
        return '/login';
      }

      // Security: If user is NOT logged in, they can only access splash or login
      if (user == null) {
        if (!isLoggingIn && !isSplash) {
          return '/login';
        }
      }

      // UX: If user IS logged in, prevent them from going back to login screen
      if (user != null && user.isActive && isLoggingIn) {
        return '/wagons';
      }

      if (user != null &&
          state.uri.path.startsWith('/admin') &&
          !user.role.canManageUsers) {
        return '/wagons';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/manual',
        name: 'manual',
        builder: (context, state) => const RootBackGuard(
          fallbackLocation: '/wagons',
          child: UserManualScreen(),
        ),
      ),
      GoRoute(
        path: '/legal',
        name: 'legal',
        builder: (context, state) => const RootBackGuard(
          fallbackLocation: '/wagons',
          child: LegalPrivacyScreen(),
        ),
      ),
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/registers',
        name: 'register_list',
        builder: (context, state) => const RootBackGuard(
          fallbackLocation: '/wagons',
          child: RegisterListScreen(),
        ),
        routes: [
          GoRoute(
            path: ':id',
            name: 'register_details',
            builder: (context, state) => RootBackGuard(
              fallbackLocation: '/registers',
              child: RegisterDetailsScreen(
                registerId: state.pathParameters['id'] ?? '',
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/wagons',
        name: 'wagon_list',
        builder: (context, state) => const WagonListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'wagon_details',
            builder: (context, state) => RootBackGuard(
              fallbackLocation: '/wagons',
              child: WagonDetailsScreen(
                wagonId: state.pathParameters['id'] ?? '',
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/trucks/:id',
        name: 'truck_details',
        builder: (context, state) => RootBackGuard(
          fallbackLocation: '/wagons',
          child: TruckDetailsScreen(
            truckId: state.pathParameters['id'] ?? '',
            fallbackTruck:
                (state.extra as Map<String, dynamic>?)?['truck'] as Truck?,
            allowArchivedEditing:
                ((state.extra as Map<String, dynamic>?)?['allowArchivedEditing']
                        as bool?) ??
                    false,
            isRegisterView: ((state.extra
                    as Map<String, dynamic>?)?['isRegisterView'] as bool?) ??
                false,
          ),
        ),
        routes: [
          GoRoute(
            path: 'camera',
            name: 'camera',
            builder: (context, state) => CaptureWorkspaceScreen(
              truckId: state.pathParameters['id'] ?? '',
            ),
            routes: [
              GoRoute(
                path: 'live',
                name: 'camera_live',
                builder: (context, state) => CaptureWorkspaceScreen(
                  truckId: state.pathParameters['id'] ?? '',
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'count-method',
            name: 'count_method',
            redirect: (context, state) =>
                '/trucks/${state.pathParameters['id'] ?? ''}/camera',
          ),
          GoRoute(
            path: 'manual-count',
            name: 'manual_count',
            builder: (context, state) => CaptureWorkspaceScreen(
              truckId: state.pathParameters['id'] ?? '',
              initialMode: CountMode.manual,
            ),
          ),
          GoRoute(
            path: 'review',
            name: 'layer_review',
            pageBuilder: (context, state) {
              final truckId = state.pathParameters['id'] ?? '';
              final extra = state.extra as Map<String, dynamic>? ?? {};
              final aiResult = extra['aiResult'] as AIResult? ??
                  AIResult(
                    detections: const [],
                    count: 0,
                    averageConfidence: 0.9,
                    processingTimeMs: 12.0,
                    modelVersion: AIModel.activeVersion,
                    inferenceTimestamp: DateTime.now(),
                    frameSize: const Size(720, 1280),
                  );
              final photoPath = extra['photoPath'] as String?;
              final auditPhotoPath = extra['auditPhotoPath'] as String?;
              final countingRegion = extra['countingRegion'] as CountingRegion?;
              final initialNotes = extra['initialNotes'] as String?;
              final finalResultLoader =
                  extra['finalResultLoader'] as Future<AIResult> Function()?;
              final returnResultOnly =
                  extra['returnResultOnly'] as bool? ?? false;
              final navigateToControlCenter =
                  extra['navigateToControlCenter'] as bool? ?? false;

              return NoTransitionPage(
                child: LayerReviewScreen(
                  truckId: truckId,
                  aiResult: aiResult,
                  photoPath: photoPath,
                  auditPhotoPath: auditPhotoPath,
                  countingRegion: countingRegion,
                  initialNotes: initialNotes,
                  finalResultLoader: finalResultLoader,
                  returnResultOnly: returnResultOnly,
                  navigateToControlCenter: navigateToControlCenter,
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const RootBackGuard(
          fallbackLocation: '/wagons',
          child: AiCameraSettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const RootBackGuard(
          fallbackLocation: '/wagons',
          child: AnalyticsDashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const RootBackGuard(
          fallbackLocation: '/wagons',
          child: ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/security',
        name: 'admin_security',
        builder: (context, state) => const RootBackGuard(
          fallbackLocation: '/wagons',
          child: AdminSecurityScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/security/users',
        name: 'admin_users',
        builder: (context, state) => const RootBackGuard(
          fallbackLocation: '/admin/security',
          child: UserManagementScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/security/roles',
        name: 'admin_roles',
        builder: (context, state) => const RootBackGuard(
          fallbackLocation: '/admin/security',
          child: RolePoliciesScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) => RootBackGuard(
      fallbackLocation: '/wagons',
      child: _RecoveryPage(
        title: 'Page Not Found',
        message: 'The requested page (${state.uri}) is not available.',
      ),
    ),
  );
});

class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(Ref ref) {
    ref.listen<User?>(authProvider, (_, __) => notifyListeners());
  }
}

class _RecoveryPage extends StatelessWidget {
  final String title;
  final String message;

  const _RecoveryPage({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/wagons'),
        ),
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline_rounded, size: 48),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.go('/wagons'),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Wagon Control Center'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
