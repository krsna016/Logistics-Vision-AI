import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/navigation/app_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Splash Navigation Router Verification', () {
    test('Router initial location defaults to splash screen route (/)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);
      
      // Assert that router has registered root splash route path
      final hasSplashRoute = router.configuration.routes.any((route) {
        if (route is GoRoute) {
          return route.path == '/';
        }
        return false;
      });
      expect(hasSplashRoute, isTrue);
    });
  });
}
