import 'package:flower_app/config/di/di.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';

import 'package:flower_app/features/auth/presentation/forget_password/bloc/forget_password_bloc.dart';
import 'package:flower_app/features/auth/presentation/forget_password/views/forget_password_flow_view.dart';
import 'package:flower_app/features/auth/presentation/login/manager/login_cubit.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_view_model.dart';
import 'package:flower_app/features/auth/presentation/register/views/register_view.dart';
import 'package:flower_app/core/widgets/coming_soon_view.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flower_app/features/commerce/presentation/best_seller/view/best_seller_view.dart';
import 'package:flower_app/features/commerce/presentation/best_seller/view_model/best_seller_view_model.dart';
import 'package:flower_app/features/commerce/presentation/categories/manager/categories_cubit.dart';
import 'package:flower_app/features/commerce/presentation/categories/manager/categories_events.dart';
import 'package:flower_app/features/commerce/presentation/categories/view/categories_view.dart';
import 'package:flower_app/features/commerce/presentation/home/manager/home_cubit.dart';
import 'package:flower_app/features/commerce/presentation/home/manager/home_events.dart';
import 'package:flower_app/features/commerce/presentation/occasions/manager/occasions_cubit.dart';
import 'package:flower_app/features/commerce/presentation/occasions/manager/occasions_events.dart';
import 'package:flower_app/features/commerce/presentation/occasions/view/occasions_view.dart';
import 'package:flower_app/features/commerce/presentation/product_details/view/product_details_view.dart';
import 'package:flower_app/features/commerce/presentation/product_details/view_model/product_details_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/Address/presentaion/manager/address_cubit.dart';
import '../../features/Address/presentaion/manager/address_events.dart';
import '../../features/Address/presentaion/view/add_address_view.dart';
import '../../features/auth/presentation/login/views/login_view.dart';
import '../../features/commerce/presentation/home/view/home_view.dart';
import 'main_shell_view.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.login,

    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<LoginCubit>(),
          child: const LoginView(),
        ),
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
                builder: (context, state) => MultiBlocProvider(
                  providers: [
                    BlocProvider<HomeCubit>(
                      create: (_) =>
                          getIt<HomeCubit>()..doEvents(HomeStarted()),
                    ),
                    BlocProvider<AddressCubit>(
                      create: (_) =>
                          getIt<AddressCubit>()
                            ..doEvents(ResolveHomeAddressEvent()),
                    ),
                  ],
                  child: const HomeView(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.categories,
                builder: (context, state) {
                  final categoryId =
                      state.uri.queryParameters[AppRoutes.categoryIdParam];
                  return BlocProvider(
                    // the path never changes, so keying on the category is
                    // what makes a tap on Home rebuild the cubit for it
                    key: ValueKey(categoryId),
                    create: (_) => getIt<CategoriesCubit>()
                      ..doEvents(
                        CategoriesStarted(initialCategoryId: categoryId),
                      ),
                    child: const CategoriesView(),
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
                    const ComingSoonView(title: 'Cart'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) =>
                    const ComingSoonView(title: 'Profile'),
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
        path: AppRoutes.bestSeller,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<BestSellerViewModel>(),
          child: const BestSellerView(),
        ),
      ),

      GoRoute(
        path: AppRoutes.addAddress,
        builder: (context, state) => BlocProvider.value(
          value: getIt<AddressCubit>()..doEvents(const GetAreasWithCitiesEvent()),
          child: const AddAddressView(),
        ),
      ),
      GoRoute(
        path: AppRoutes.productDetails,
        builder: (context, state) {
          final product = state.extra as ProductEntity?;
          return BlocProvider(
            create: (_) => getIt<ProductDetailsViewModel>(),
            child: ProductDetailsView(product: product),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.occasions,
        builder: (context, state) {
          final occasionId =
              state.uri.queryParameters[AppRoutes.occasionIdParam];
          return BlocProvider(
            create: (_) =>
                getIt<OccasionsCubit>()
                  ..doEvents(OccasionsStarted(initialOccasionId: occasionId)),
            child: const OccasionsView(),
          );
        },
      ),
    ],
  );
}
