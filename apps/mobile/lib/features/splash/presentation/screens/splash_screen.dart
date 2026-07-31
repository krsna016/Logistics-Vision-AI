import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/domain/entities/user.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _indicatorFade;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Staggered animations mapping:
    // 1. Logo scales up between 0% and 40% timeline progress
    // Keep the Flutter logo at the exact native launch size from the first
    // rendered frame so there is no scale jump during the handoff.
    _logoScale = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    // 4. Loading indicator fades in at the end
    _indicatorFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Staggered navigation trigger once animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () async {
          if (mounted && !_hasNavigated) {
            // Check if user is logged in
            User? user;
            // AuthNotifier restores the saved session asynchronously during
            // startup. Give it time to finish before deciding to show Login.
            for (var attempt = 0; attempt < 20; attempt++) {
              user = ref.read(authProvider);
              if (user != null) break;
              await Future<void>.delayed(const Duration(milliseconds: 100));
            }

            if (mounted && !_hasNavigated) {
              _hasNavigated = true;
              if (user != null) {
                // Manually update the state notifier so the app knows who is logged in
                // (In a real app you'd have an init method on AuthNotifier)
                context.go('/wagons');
              } else {
                context.go('/login');
              }
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFF0F2027),
      body: Stack(
        children: [
          // The logo is centered independently, matching the native launch
          // screen. Text below it must not change the logo's position.
          Center(
            child: ScaleTransition(
              scale: _logoScale,
              child: Image.asset(
                'assets/images/logo.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
          ),

          Positioned(
            top: size.height / 2 + 102,
            left: 0,
            right: 0,
            child: const Column(
              children: [
                // Company Title
                Text(
                  'Vinayak SmartLoad',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 12),

                // Subtitle
                Text(
                  'Powered by Vinayak Logistics',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Bottom loading indicators & version details
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _indicatorFade,
              child: Column(
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white24 : Colors.grey.shade400,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
