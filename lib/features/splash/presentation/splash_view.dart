// lib/features/splash/presentation/screens/splash_screen.dart
import 'package:flower_app/core/app_constants/app_assets.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

import '../../../config/di/di.dart';
import '../../../config/notificaions/fcm.dart';
import '../../../config/notificaions/fcm_token_sync_service.dart';
import '../../../core/app_theme/extension_theme_color.dart';
import '../../auth/data/data_source/local/auth_local_data_source.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Run FCM setup and minimum display timer in parallel
    await Future.wait([
      getIt<Fcm>().initialize(),
      getIt<FcmTokenSyncService>().initFcmTokenSync(),
      Future.delayed(const Duration(seconds: 2)),
    ]);

    if (!mounted) return;

    // Remove the native splash screen if preserved
    FlutterNativeSplash.remove();

    // Check user authentication status
    final token = await getIt<AuthLocalDataSource>().getToken();
    final isAuthenticated = token != null && token.isNotEmpty;

    if (!mounted) return;

    // Replace route stack so user cannot back-navigate to Splash
    if (isAuthenticated) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(AppAssets.logo),
            ),
            const SizedBox(height: 20),
            Text(
              'Flowery',
              style: context.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: context.colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}