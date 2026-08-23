import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/core/validation/validation.dart';
import 'package:flower_app/features/auth/presentation/login/manager/login_cubit.dart';
import 'package:flower_app/features/auth/presentation/login/manager/login_events.dart';
import 'package:flower_app/features/auth/presentation/login/manager/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/di/di.dart';
import '../../../../../core/guest_browsing/guest_browsing_provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> formKey = GlobalKey();

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = LightColors();
    LoginCubit cubit = context.read<LoginCubit>();

    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) async {
        if (state.loginResource.isError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.loginResource.errorMessage ?? "")),
          );
        }

        if (state.loginResource.isSuccess) {
          final guestBrowsingProvider = getIt<GuestBrowsingProvider>();

          if (guestBrowsingProvider.hasPendingAction) {
            await guestBrowsingProvider.executePendingAction();
          } else {
            context.go(AppRoutes.home);
          }
        }
      },

      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          titleSpacing: 0,
          title: Text(AppStrings.login.tr()),
        ),

        body: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: AppStrings.enterYourEmail.tr(),
                        labelText: AppStrings.email.tr(),
                      ),
                      onChanged: (value) {
                        cubit.doEvents(EmailChanged(value));
                      },
                      validator: Validation.validateEmail,
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BlocBuilder<LoginCubit, LoginState>(
                      buildWhen: (previous, current) =>
                          previous.obscurePassword != current.obscurePassword,
                      builder: (context, state) {
                        return TextFormField(
                          obscureText: state.obscurePassword,
                          decoration: InputDecoration(
                            hintText: AppStrings.enterYourPassword.tr(),
                            labelText: AppStrings.password.tr(),
                            suffixIcon: IconButton(
                              onPressed: () {
                                context.read<LoginCubit>().doEvents(
                                  PasswordVisibilityChanged(),
                                );
                              },
                              icon: Icon(
                                state.obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            context.read<LoginCubit>().doEvents(
                              PasswordChanged(value),
                            );
                          },
                          validator: Validation.validatePassword,
                        );
                        // Password
                      },
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(width: 8),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.check_box_outline_blank_rounded),
                      ),
                      const SizedBox(width: 4),
                      Text(AppStrings.rememberMe.tr()),
                    Spacer(),
                      Text(
                        AppStrings.forget_password.tr(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(width: 8,)
                    ],
                  ),
                  SizedBox(height: 70),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: BlocBuilder<LoginCubit, LoginState>(
                      buildWhen: (previous, current) =>
                          previous.loginResource.status !=
                          current.loginResource.status,
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state.loginResource.isLoading
                              ? null
                              : () {
                                  if (formKey.currentState!.validate()) {
                                    cubit.doEvents(LoginSubmitted());
                                  }
                                },
                          child: state.loginResource.isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(AppStrings.login.tr()),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        fixedSize: const Size.fromHeight(50),
                      ),
                      onPressed: () {
                        context.push(AppRoutes.home);
                      },
                      child: Text(
                        AppStrings.continueAsGuest.tr(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.dontHaveAnAccount.tr(),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        InkWell(
                          onTap: () {
                            context.push(AppRoutes.register);
                          },
                          child: Text(
                            AppStrings.signUp.tr(),
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: colors.error,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.red,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
