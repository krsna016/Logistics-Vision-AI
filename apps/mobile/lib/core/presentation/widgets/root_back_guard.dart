import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Handles Android back after GoRouter reports that its history is empty.
class SmartLoadBackButtonDispatcher extends RootBackButtonDispatcher {
  final GoRouter router;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  DateTime? _lastHomeBack;

  SmartLoadBackButtonDispatcher({
    required this.router,
    required this.scaffoldMessengerKey,
  });

  @override
  Future<bool> didPopRoute() async {
    if (await super.didPopRoute()) return true;
    final path = router.routeInformationProvider.value.uri.path;
    if (path != '/wagons') {
      router.go(_fallbackFor(path));
      return true;
    }

    final now = DateTime.now();
    if (_lastHomeBack != null &&
        now.difference(_lastHomeBack!) <= const Duration(seconds: 2)) {
      SystemNavigator.pop();
      return true;
    }
    _lastHomeBack = now;
    scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit the app.'),
          duration: Duration(seconds: 2),
        ),
      );
    return true;
  }

  String _fallbackFor(String path) {
    if (path.startsWith('/registers/')) return '/registers';
    if (path.startsWith('/admin/security/') || path == '/admin/backup') {
      return '/admin/security';
    }
    return '/wagons';
  }
}

/// Gives a standalone route a safe in-app destination for system/gesture back.
class RootBackGuard extends StatefulWidget {
  final String fallbackLocation;
  final Widget child;

  const RootBackGuard({
    super.key,
    required this.fallbackLocation,
    required this.child,
  });

  @override
  State<RootBackGuard> createState() => _RootBackGuardState();
}

class _RootBackGuardState extends State<RootBackGuard> {
  bool _allowPop = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !mounted) return;
        final hasPreviousPage = Navigator.of(context).canPop();
        if (hasPreviousPage) setState(() => _allowPop = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (hasPreviousPage) {
            Navigator.of(context).pop(result);
          } else {
            context.go(widget.fallbackLocation);
          }
        });
      },
      child: widget.child,
    );
  }
}

/// Prevents one accidental gesture from immediately closing the home screen.
class DoubleBackToExitGuard extends StatefulWidget {
  final Widget child;
  final Duration confirmationWindow;

  const DoubleBackToExitGuard({
    super.key,
    required this.child,
    this.confirmationWindow = const Duration(seconds: 2),
  });

  @override
  State<DoubleBackToExitGuard> createState() => _DoubleBackToExitGuardState();
}

class _DoubleBackToExitGuardState extends State<DoubleBackToExitGuard> {
  DateTime? _lastBackAttempt;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final now = DateTime.now();
        final previous = _lastBackAttempt;
        if (previous != null &&
            now.difference(previous) <= widget.confirmationWindow) {
          SystemNavigator.pop();
          return;
        }
        _lastBackAttempt = now;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit the app.'),
              duration: Duration(seconds: 2),
            ),
          );
      },
      child: widget.child,
    );
  }
}
