import 'package:flower_app/config/di/di.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/features/auth/presentation/forget_password/bloc/forget_password_bloc.dart';
import 'package:flower_app/features/auth/presentation/forget_password/views/forget_password_view.dart';
import 'package:flower_app/features/auth/presentation/forget_password/views/otp_verification_view.dart';
import 'package:flower_app/features/auth/presentation/forget_password/views/reset_password_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login/views/login_view.dart';
import '../../features/home/presentation/home_view.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,

    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginView(),
      ),

      ShellRoute(
        builder: (context, state, child) => BlocProvider(
          create: (_) => getIt<ForgetPasswordBloc>(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.forgotPassword,
            builder: (context, state) => const ForgetPasswordView(),
          ),
          GoRoute(
            path: AppRoutes.otpVerification,
            builder: (context, state) => const OtpVerificationView(),
          ),
          GoRoute(
            path: AppRoutes.resetPassword,
            builder: (context, state) => const ResetPasswordView(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeView(),
      ),
    ],
  );
}
