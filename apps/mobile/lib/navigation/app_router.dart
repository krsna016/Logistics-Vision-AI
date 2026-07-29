import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/camera/presentation/screens/camera_screen.dart';
import '../features/camera/presentation/screens/count_method_screens.dart';
import '../features/truck/presentation/screens/truck_details_screen.dart';
import '../features/layer/presentation/screens/layer_review_screen.dart';
import '../features/layer/domain/entities/ai_result.dart';

import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/wagon/presentation/screens/wagon_list_screen.dart';
import '../features/wagon/presentation/screens/wagon_details_screen.dart';

import '../features/register/presentation/screens/register_list_screen.dart';
import '../features/register/presentation/screens/register_details_screen.dart';
import '../core/presentation/screens/user_manual_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/profile_screen.dart';
import '../features/auth/presentation/screens/admin_security_screen.dart';
import '../features/auth/presentation/screens/user_management_screen.dart';
import '../features/auth/presentation/screens/role_policies_screen.dart';
import '../features/auth/presentation/screens/device_management_screen.dart';
import '../features/auth/presentation/screens/global_audit_screen.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/auth/domain/entities/user.dart';
import '../features/sync/presentation/screens/backup_management_screen.dart';

// Router provider representing Riverpod-based dependency injection for GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  // Keep one stable router during startup. Refresh route guards from auth
  // changes without recreating GoRouter and resetting the initial route.
  final authRefresh = _AuthRouterRefresh(ref);
  return GoRouter(
    initialLocation: '/', // default to splash
    refreshListenable: authRefresh,
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

      return null;
    },
    routes: [
      GoRoute(
        path: '/manual',
        name: 'manual',
        builder: (context, state) => const UserManualScreen(),
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
        builder: (context, state) => const RegisterListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'register_details',
            builder: (context, state) => RegisterDetailsScreen(
              registerId: state.pathParameters['id'] ?? '',
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
            builder: (context, state) => WagonDetailsScreen(
              wagonId: state.pathParameters['id'] ?? '',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/trucks/:id',
        name: 'truck_details',
        builder: (context, state) => TruckDetailsScreen(
          truckId: state.pathParameters['id'] ?? '',
        ),
        routes: [
          GoRoute(
            path: 'camera',
            name: 'camera',
            builder: (context, state) => CountMethodSelectionScreen(
              truckId: state.pathParameters['id'] ?? '',
            ),
            routes: [
              GoRoute(
                path: 'live',
                name: 'camera_live',
                builder: (context, state) => const CameraScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'count-method',
            name: 'count_method',
            builder: (context, state) => CountMethodSelectionScreen(
              truckId: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: 'manual-count',
            name: 'manual_count',
            builder: (context, state) => ManualCountScreen(
              truckId: state.pathParameters['id'] ?? '',
            ),
          ),
          GoRoute(
            path: 'review',
            name: 'layer_review',
            builder: (context, state) {
              final truckId = state.pathParameters['id'] ?? '';
              final extra = state.extra as Map<String, dynamic>? ?? {};
              final aiResult = extra['aiResult'] as AIResult? ??
                  AIResult(
                    detections: const [],
                    count: 0,
                    averageConfidence: 0.9,
                    processingTimeMs: 12.0,
                    modelVersion: '1.0.0-YOLOv8n',
                    inferenceTimestamp: DateTime.now(),
                    frameSize: const Size(720, 1280),
                  );
              final photoPath = extra['photoPath'] as String?;
              final manualNotes = extra['manualNotes'] as String?;
              return LayerReviewScreen(
                truckId: truckId,
                aiResult: aiResult,
                photoPath: photoPath,
                initialNotes: manualNotes,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Settings Screen (Placeholder)')),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route Not Found: ${state.uri}'),
      ),
    ),
  );
});

class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(Ref ref) {
    ref.listen<User?>(authProvider, (_, __) => notifyListeners());
  }
}
