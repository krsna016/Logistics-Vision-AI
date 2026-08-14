import 'core/presentation/widgets/root_back_guard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'config/environment.dart';
import 'navigation/app_router.dart';
import 'theme/app_theme.dart';
import 'utils/logger.dart';
import 'core/presentation/layout/reference_viewport.dart';
import 'features/sync/presentation/providers/sync_providers.dart';
import 'core/providers/ai_camera_settings_provider.dart';

void main() async {
  // Ensure widget bindings are loaded before background async initializes.
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // SmartLoad's operational camera, review, forms and register workflows are
  // designed as a consistent portrait workspace. Prevent accidental rotation
  // from changing controls or camera geometry between devices.
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
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
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  SmartLoadBackButtonDispatcher? _backDispatcher;
  GoRouter? _dispatcherRouter;

  SmartLoadBackButtonDispatcher _dispatcherFor(GoRouter router) {
    if (!identical(_dispatcherRouter, router)) {
      _dispatcherRouter = router;
      _backDispatcher = SmartLoadBackButtonDispatcher(
        router: router,
        scaffoldMessengerKey: _scaffoldMessengerKey,
      );
    }
    return _backDispatcher!;
  }

  @override
  void initState() {
    super.initState();
    // Keep the offline queue engine alive for the whole app session. It must
    // not depend on the user opening the backup screen first.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncEngineProvider);
      ref.read(aiCameraSettingsLoaderProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      backButtonDispatcher: _dispatcherFor(router),
      title: 'Vinayak SmartLoad',
      debugShowCheckedModeBanner:
          Environment.current == Environment.development,

      // Theme settings
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Preserve the approved reference-phone composition across Android
      // display-density settings while retaining native insets and gestures.
      builder: (context, child) => SmartLoadReferenceViewport(
        child: child ?? const SizedBox.shrink(),
      ),

      // GoRouter navigation bindings. These are supplied individually so the
      // app can install its root Android back dispatcher.
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
    );
  }
}
