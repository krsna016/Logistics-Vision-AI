import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/environment.dart';
import 'navigation/app_router.dart';
import 'theme/app_theme.dart';
import 'utils/logger.dart';

void main() async {
  // Ensure widget bindings are loaded before background async initializes.
  WidgetsFlutterBinding.ensureInitialized();

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

class LogisticsVisionApp extends ConsumerWidget {
  const LogisticsVisionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        final textScale =
            MediaQuery.textScalerOf(context).scale(1).clamp(0.9, 1.1);
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
