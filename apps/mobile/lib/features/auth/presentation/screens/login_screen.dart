import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/login_card.dart';
import '../../../../core/presentation/layout/responsive.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppResponsive.pagePadding(context),
                vertical: 24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Container(
                    padding: const EdgeInsets.all(0),
                    child: Image.asset('assets/images/logo.png',
                        width: 80, height: 80, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vinayak SmartLoad',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Powered by Vinayak Logistics',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Login Card
                  LoginCard(
                    onLoginSuccess: () {
                      context.go('/wagons');
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
