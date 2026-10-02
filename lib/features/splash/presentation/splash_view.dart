import 'package:flower_app/core/app_constants/app_assets.dart';
import 'package:flower_app/core/app_theme/extension_theme_color.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

import 'manager/splash_cubit.dart';
import 'manager/splash_state.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
// Dismiss the native splash so the Flutter flower splash is visible
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        switch (state) {
          case SplashAuthenticated():
            context.go(AppRoutes.home);
          case SplashUnauthenticated():
            context.go(AppRoutes.login);
          case SplashInitial():
            break;
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: Center(
          child: SizedBox(
            width: 160,
            height: 160,
            child: Image.asset(
              AppAssets.flowerImage,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
