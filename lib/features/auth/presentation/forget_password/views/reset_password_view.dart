import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/validation/validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/forget_password_bloc.dart';
import '../bloc/forget_password_event.dart';
import '../bloc/forget_password_state.dart';
import '../widgets/auth_header_text.dart';
import '../widgets/auth_submit_button.dart';

/// Third step of [ForgetPasswordFlowView]. The scaffold, app bar and ui action
/// handling belong to the flow, not to the individual step.
class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
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
    );
  }
}
