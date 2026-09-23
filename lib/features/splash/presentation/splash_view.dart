import 'package:flower_app/core/app_constants/app_assets.dart';
import 'package:flower_app/core/app_theme/extension_theme_color.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

import 'manager/splash_cubit.dart';
import 'manager/splash_state.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashAuthenticated) {
          FlutterNativeSplash.remove();
          context.go(AppRoutes.home);
        } else if (state is SplashUnauthenticated) {
          FlutterNativeSplash.remove();
          context.go(AppRoutes.login);
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