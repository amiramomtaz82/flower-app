import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/features/auth/presentation/forget_password/views/forget_password_view.dart';
import 'package:flower_app/features/auth/presentation/login/manager/login_cubit.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../config/di/di.dart';
import '../../features/auth/presentation/login/views/login_view.dart';
import '../../features/home/presentation/views/home_view.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,

    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => BlocProvider(
          create: (_)=>getIt<LoginCubit>(),
           child:const LoginView())

        ),

      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgetPasswordView(),
      ),

      GoRoute
        (
        path: AppRoutes.home,
        builder: (context, state) => const HomeView(),
      ),
    ],
  );
}
