import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/forget_password_bloc.dart';
import '../bloc/forget_password_event.dart';
import '../bloc/forget_password_state.dart';
import '../widgets/auth_header_text.dart';
import '../widgets/otp_holder.dart';

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({super.key});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _onCompleted(String code) {
    context.read<ForgetPasswordBloc>().add(VerifyResetCodeEvent(code));
  }

  void _onResend() {
    final bloc = context.read<ForgetPasswordBloc>();
    bloc.add(SendResetCodeEvent(bloc.state.email, isResend: true));
  }

  void _handleUiAction(BuildContext context, ForgetPasswordState state) {
    // The three screens share one bloc and stay on the stack, so only the
    // visible one may act on a ui action.
    if (ModalRoute.of(context)?.isCurrent != true) return;

    switch (state.uiAction.type) {
      case ForgetPasswordUiActionType.goToResetPassword:
        context.push(AppRoutes.resetPassword);
      case ForgetPasswordUiActionType.showSuccess:
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
            children: [
              const AuthHeaderText(
                title: AppStrings.emailVerification,
                subtitle: AppStrings.enterCodeSentToEmail,
              ),
              const SizedBox(height: 20),
              BlocBuilder<ForgetPasswordBloc, ForgetPasswordState>(
                buildWhen: (previous, current) =>
                    previous.otpErrorMessage != current.otpErrorMessage ||
                    previous.isVerifyingCode != current.isVerifyingCode,
                builder: (context, state) => Column(
                  children: [
                    OtpHolder(
                      controller: _otpController,
                      errorText: state.otpErrorMessage?.tr(),
                      onChanged: (_) => context.read<ForgetPasswordBloc>().add(
                        OtpChangedEvent(),
                      ),
                      onCompleted: _onCompleted,
                    ),
                    if (state.isVerifyingCode)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.dontReceiveCode.tr(),
                    style: appTheme.textTheme.bodyMedium,
                  ),
                  BlocSelector<ForgetPasswordBloc, ForgetPasswordState, bool>(
                    selector: (state) => state.isSendingCode,
                    builder: (context, isSendingCode) => TextButton(
                      onPressed: isSendingCode ? null : _onResend,
                      child: Text(
                        AppStrings.resend.tr(),
                        style: appTheme.textTheme.bodyMedium?.copyWith(
                          color: LightColors().primary,
                          decoration: TextDecoration.underline,
                          decorationColor: LightColors().primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
