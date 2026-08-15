import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/core/validation/validation.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/forget_password_bloc.dart';
import '../bloc/forget_password_event.dart';
import '../bloc/forget_password_state.dart';
import '../widgets/auth_app_bar.dart';
import '../widgets/auth_header_text.dart';
import '../widgets/auth_submit_button.dart';

class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({super.key});

  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (_formKey.currentState!.validate()) {
      context.read<ForgetPasswordBloc>().add(
        SendResetCodeEvent(_emailController.text.trim()),
      );
    }
  }

  void _handleUiAction(BuildContext context, ForgetPasswordState state) {
    if (ModalRoute.of(context)?.isCurrent != true) return;

    switch (state.uiAction.type) {
      case ForgetPasswordUiActionType.goToOtp:
        context.push(AppRoutes.otpVerification);
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
    return Scaffold(
      appBar: const AuthAppBar(title: AppStrings.password),
      body: BlocListener<ForgetPasswordBloc, ForgetPasswordState>(
        listenWhen: (previous, current) =>
            previous.uiAction != current.uiAction,
        listener: _handleUiAction,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            spacing: 20,
            children: [
              const AuthHeaderText(
                title: AppStrings.forgetPassword,
                subtitle: AppStrings.enterEmailAssociatedToAccount,
              ),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: AppStrings.email.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validation.validateEmail,
                ),
              ),
              BlocSelector<ForgetPasswordBloc, ForgetPasswordState, bool>(
                selector: (state) => state.isSendingCode,
                builder: (context, isSendingCode) => AuthSubmitButton(
                  label: AppStrings.confirm,
                  isLoading: isSendingCode,
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
