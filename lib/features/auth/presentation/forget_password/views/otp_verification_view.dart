import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class _OtpVerificationViewState extends State<OtpVerificationView>
    with AutomaticKeepAliveClientMixin {
  final _otpController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final appTheme = Theme.of(context);
    return Padding(
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
                  onChanged: (_) =>
                      context.read<ForgetPasswordBloc>().add(OtpChangedEvent()),
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
              BlocSelector<
                ForgetPasswordBloc,
                ForgetPasswordState,
                (bool, int)
              >(
                selector: (state) => (state.canResend, state.resendCooldown),
                builder: (context, selected) {
                  final (canResend, cooldown) = selected;
                  final color = canResend
                      ? LightColors().primary
                      : appTheme.disabledColor;
                  return TextButton(
                    onPressed: canResend ? _onResend : null,
                    child: Text(
                      cooldown > 0
                          ? '${AppStrings.resend.tr()} ($cooldown)'
                          : AppStrings.resend.tr(),
                      style: appTheme.textTheme.bodyMedium?.copyWith(
                        color: color,
                        decoration: TextDecoration.underline,
                        decorationColor: color,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
