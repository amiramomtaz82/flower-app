import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/core/validation/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/forget_password_bloc.dart';
import '../bloc/forget_password_event.dart';
import '../bloc/forget_password_state.dart';
import '../widgets/auth_header_text.dart';
import '../widgets/auth_submit_button.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ForgetPasswordBloc>().add(
        ResetPasswordEvent(
          _passwordController.text,
          _confirmPasswordController.text,
        ),
      );
    }
  }

  void _handleUiAction(BuildContext context, ForgetPasswordState state) {
    // The three screens share one bloc and stay on the stack, so only the
    // visible one may act on a ui action.
    if (ModalRoute.of(context)?.isCurrent != true) return;

    switch (state.uiAction.type) {
      case ForgetPasswordUiActionType.goToLogin:
        context.go(AppRoutes.login);
      // The reset token expired, so step back to the otp screen this flow was
      // pushed from — it carries the reason inline and the resend button.
      case ForgetPasswordUiActionType.goToOtp:
        context.pop();
      case ForgetPasswordUiActionType.showError:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.uiAction.message?.tr() ?? '')),
        );
      default:
        return;
    }
    context.read<ForgetPasswordBloc>().add(ClearUiActionEvent());
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            context.pop();
          },
        ),
        titleSpacing: 0,
        title: Text(
          AppStrings.password.tr(),
          style: appTheme.textTheme.titleLarge,
        ),
      ),
      body: BlocListener<ForgetPasswordBloc, ForgetPasswordState>(
        listenWhen: (previous, current) =>
            previous.uiAction != current.uiAction,
        listener: _handleUiAction,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 20,
            children: [
              const AuthHeaderText(
                title: AppStrings.resetPassword,
                subtitle: AppStrings.passwordRules,
              ),
              Form(
                key: _formKey,
                child: Column(
                  spacing: 20,
                  children: [
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: AppStrings.newPassword.tr(),
                        hintText: AppStrings.enterYourPassword.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: Validation.validatePassword,
                    ),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: AppStrings.confirmPassword.tr(),
                        hintText: AppStrings.confirmPassword.tr(),
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) => Validation.validateConfirmPassword(
                        value,
                        _passwordController.text,
                      ),
                    ),
                  ],
                ),
              ),
              BlocSelector<ForgetPasswordBloc, ForgetPasswordState, bool>(
                selector: (state) => state.isResettingPassword,
                builder: (context, isResetting) => AuthSubmitButton(
                  label: AppStrings.confirm,
                  isLoading: isResetting,
                  onPressed: _onConfirm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
