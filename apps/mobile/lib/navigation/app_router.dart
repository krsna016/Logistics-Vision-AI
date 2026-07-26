import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/camera/presentation/screens/camera_screen.dart';
import '../features/truck/presentation/screens/truck_list_screen.dart';
import '../features/truck/presentation/screens/truck_details_screen.dart';
import '../features/layer/presentation/screens/layer_review_screen.dart';
import '../features/layer/domain/entities/ai_result.dart';
import '../features/dataset/presentation/screens/dataset_browser_screen.dart';
import '../features/dataset/presentation/screens/dataset_collection_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/wagon/presentation/screens/wagon_list_screen.dart';
import '../features/wagon/presentation/screens/wagon_details_screen.dart';

import '../features/register/presentation/screens/register_list_screen.dart';
import '../features/register/presentation/screens/register_details_screen.dart';
import '../core/presentation/screens/user_manual_screen.dart';

// Router provider representing Riverpod-based dependency injection for GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
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
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Login Screen (Placeholder)')),
        ),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Dashboard Screen (Placeholder)')),
        ),
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
        path: '/trucks',
        name: 'truck_list',
        builder: (context, state) => const TruckListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'truck_details',
            builder: (context, state) => TruckDetailsScreen(
              truckId: state.pathParameters['id'] ?? '',
            ),
            routes: [
              GoRoute(
                path: 'camera',
                name: 'camera',
                builder: (context, state) => const CameraScreen(),
              ),
              GoRoute(
                path: 'review',
                name: 'layer_review',
                builder: (context, state) {
                  final truckId = state.pathParameters['id'] ?? '';
                  final extra = state.extra as Map<String, dynamic>? ?? {};
                  final aiResult = extra['aiResult'] as AIResult? ?? AIResult(
                    detections: const [],
                    count: 0,
                    averageConfidence: 0.9,
                    processingTimeMs: 12.0,
                    modelVersion: '1.0.0-YOLOv8n',
                    inferenceTimestamp: DateTime.now(),
                    frameSize: const Size(720, 1280),
                  );
                  final photoPath = extra['photoPath'] as String?;
                  return LayerReviewScreen(
                    truckId: truckId,
                    aiResult: aiResult,
                    photoPath: photoPath,
                  );
                },
              ),
            ],
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
      GoRoute(
        path: '/dataset',
        name: 'dataset_browser',
        builder: (context, state) => const DatasetBrowserScreen(),
        routes: [
          GoRoute(
            path: 'collect',
            name: 'dataset_collect',
            builder: (context, state) => const DatasetCollectionScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route Not Found: ${state.uri}'),
      ),
    ),
  );
});

