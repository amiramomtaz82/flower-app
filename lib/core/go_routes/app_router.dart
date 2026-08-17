import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/config/di/di.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_view_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flower_app/features/auth/presentation/forget_password/views/forget_password_view.dart';
import 'package:flower_app/features/auth/presentation/register/views/register_view.dart';
import 'package:go_router/go_router.dart';


import '../../features/home/presentation/home_view.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.register,

    routes: [

      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<RegisterViewModel>(),
          child: const RegisterView(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgetPasswordView(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeView(),
      ),
    ],
  );
}
