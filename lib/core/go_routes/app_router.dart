import 'package:flower_app/config/di/di.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/features/auth/presentation/forget_password/bloc/forget_password_bloc.dart';
import 'package:flower_app/features/auth/presentation/forget_password/views/forget_password_flow_view.dart';
import 'package:flower_app/features/auth/presentation/login/manager/login_cubit.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_view_model.dart';
import 'package:flower_app/features/auth/presentation/register/views/register_view.dart';
import 'package:flower_app/features/commerce/domain/entities/occasion_entity.dart';
import 'package:flower_app/features/commerce/presentation/home/view/cart_view.dart';
import 'package:flower_app/features/commerce/presentation/home/view/category_view.dart';
import 'package:flower_app/features/commerce/presentation/home/view/ocassion_product_view.dart';
import 'package:flower_app/features/commerce/presentation/home/view/profile_view.dart';
import 'package:flower_app/features/commerce/presentation/category/view/category_products_view.dart';
import 'package:flower_app/features/commerce/presentation/product_details/view/product_details_view.dart';
import 'package:flower_app/features/commerce/presentation/widgets/test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login/views/login_view.dart';
import '../../features/commerce/presentation/home/view/home_view.dart';
import 'main_shell_view.dart';


class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.home,

    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<LoginCubit>(),
          child: const LoginView(),
        ),
      ),
    GoRoute(
  path: AppRoutes.occasionProducts,
  builder: (context, state) {
    final occasionId =
        state.uri.queryParameters['occasionId'];

    return OccasionProductsView(
      selectedOccasionId: occasionId,
    );
  },
),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<ForgetPasswordBloc>(),
          child: const ForgetPasswordFlowView(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShellView(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeView(),
                routes: [
                  GoRoute(
                    path: AppRoutes.categoryProducts,
                    builder: (context, state) => CategoryProductsView(
                      categoryId: state.pathParameters['categoryId']!,
                      categoryName: state.extra as String?,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
             GoRoute(
  path: AppRoutes.categories,
  builder: (context, state) {
    final categoryId = state.uri.queryParameters['categoryId'];

    return CategoryView(
      key: ValueKey(categoryId),
      selectedCategoryId: categoryId,
    );
  },
),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cart,
                builder: (context, state) =>
                     CartView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) =>
                    const ProfileView(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<RegisterViewModel>(),
          child: const RegisterView(),
        ),
      ),

      GoRoute(
        path: AppRoutes.test,
        builder: (context, state) =>  const TestView(),
        ),
      GoRoute(
        path: AppRoutes.productDetails,
        builder: (context, state) =>  const ProductDetailsView(),
      ),
    ],
  );


}
