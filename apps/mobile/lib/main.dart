import 'dart:ui';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/environment.dart';
import 'navigation/app_router.dart';
import 'theme/app_theme.dart';
import 'utils/logger.dart';
import 'features/auth/presentation/providers/auth_providers.dart';

void main() async {
  // Ensure widget bindings are loaded before background async initializes.
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Setup Global Exception Handlers
  FlutterError.onError = (details) {
    AppLogger.fatal(
        'Unhandled Flutter UI Exception', details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.fatal('Unhandled Platform Native Exception', error, stack);
    return true;
  };

  AppLogger.info(
      'Initializing Logistics Vision AI (${Environment.current.name.toUpperCase()})');

  runApp(
    const ProviderScope(
      child: LogisticsVisionApp(),
    ),
  );
}

class LogisticsVisionApp extends ConsumerStatefulWidget {
  const LogisticsVisionApp({super.key});

  @override
  ConsumerState<LogisticsVisionApp> createState() => _LogisticsVisionAppState();
}

class _LogisticsVisionAppState extends ConsumerState<LogisticsVisionApp> {
  @override
  void initState() {
    super.initState();
    // Ask only after the first frame, when the Android/iOS activity is ready
    // to present a native permission dialog. Tracking still starts only after
    // authentication in AuthNotifier.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_requestLocationPermission());
    });
  }

  Future<void> _requestLocationPermission() async {
    try {
      await ref.read(locationTrackingServiceProvider).requestPermission();
    } catch (error, stack) {
      AppLogger.warning('Location permission request failed', error, stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Vinayak SmartLoad',
      debugShowCheckedModeBanner:
          Environment.current == Environment.development,

      // Theme settings
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Keep layouts usable when a device has an unusually large display or
      // font setting. Individual screens still use responsive constraints.
      builder: (context, child) {
        final systemTextScale =
            MediaQuery.textScalerOf(context).scale(1).clamp(0.92, 1.03);
        final widthTextScale =
            (MediaQuery.sizeOf(context).width / 390).clamp(0.92, 1.03);
        final textScale = math.min(systemTextScale, widthTextScale);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },

      // GoRouter navigation bindings
      routerConfig: router,
    );
  }
}
