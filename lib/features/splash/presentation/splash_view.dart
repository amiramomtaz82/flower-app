// lib/features/splash/presentation/screens/splash_screen.dart
import 'package:flower_app/core/app_constants/app_assets.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_theme/extension_theme_color.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Remove native splash only after the first frame renders to prevent visual flash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });

    // 2. Setup branding animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _handleRouting();
  }

  Future<void> _handleRouting() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // TODO: Verify token via secure storage / AuthState
    const bool isAuthenticated = false;

    if (isAuthenticated) {
      context.push(AppRoutes.home);
    } else {
      context.push(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Brand Flower Icon / Vector Illustration
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(AppAssets.logo)


                  ),

                const SizedBox(height: 20),

                // Brand Name
                Text(
                  'Flowery',
                  style: context.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(height: 6),



              ],
            ),
          ),
        ),
      ),
    );
  }
}