import 'package:flower_app/core/go_routes/routes_name.dart';

import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/view/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,

    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) {
          return const LoginScreen();
        },
      ),

      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) {
          return const HomeScreen();
        },
      ),
    ],
  );
}
