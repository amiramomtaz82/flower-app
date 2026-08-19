import 'package:equatable/equatable.dart';
import 'package:flower_app/features/auth/domain/entities/reset_token_entity.dart';

enum ForgetPasswordStatus { initial, loading, success, error }

enum ForgetPasswordStep { email, otp, resetPassword }

class ForgetPasswordState extends Equatable {
  final ForgetPasswordStatus sendCodeStatus;
  final ForgetPasswordStatus verifyCodeStatus;
  final ForgetPasswordStatus resetStatus;

  final String email;

  final ResetToken? resetToken;

  final String? errorMessage;
  final ForgetPasswordStep step;

  final int resendCooldown;

  const ForgetPasswordState({
    required this.sendCodeStatus,
    required this.verifyCodeStatus,
    required this.resetStatus,
    required this.email,
    required this.resetToken,
    required this.errorMessage,
    required this.step,
    required this.resendCooldown,
  });

  factory ForgetPasswordState.initial() => const ForgetPasswordState(
    sendCodeStatus: ForgetPasswordStatus.initial,
    verifyCodeStatus: ForgetPasswordStatus.initial,
    resetStatus: ForgetPasswordStatus.initial,
    email: '',
    resetToken: null,
    errorMessage: null,
    step: ForgetPasswordStep.email,
    resendCooldown: 0,
  );

  bool get isSendingCode => sendCodeStatus == ForgetPasswordStatus.loading;
  bool get isVerifyingCode => verifyCodeStatus == ForgetPasswordStatus.loading;
  bool get isResettingPassword => resetStatus == ForgetPasswordStatus.loading;

  bool get canResend => resendCooldown == 0 && !isSendingCode;

  /// The inline error under the OTP boxes — only while the verify step failed.
  String? get otpErrorMessage =>
      verifyCodeStatus == ForgetPasswordStatus.error ? errorMessage : null;

  ForgetPasswordState copyWith({
    ForgetPasswordStatus? sendCodeStatus,
    ForgetPasswordStatus? verifyCodeStatus,
    ForgetPasswordStatus? resetStatus,
    String? email,
    ResetToken? resetToken,
    bool clearResetToken = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    ForgetPasswordStep? step,
    int? resendCooldown,
  }) => ForgetPasswordState(
    sendCodeStatus: sendCodeStatus ?? this.sendCodeStatus,
    verifyCodeStatus: verifyCodeStatus ?? this.verifyCodeStatus,
    resetStatus: resetStatus ?? this.resetStatus,
    email: email ?? this.email,
    resetToken: clearResetToken ? null : (resetToken ?? this.resetToken),
    errorMessage: clearErrorMessage
        ? null
        : (errorMessage ?? this.errorMessage),
    step: step ?? this.step,
    resendCooldown: resendCooldown ?? this.resendCooldown,
  );

  @override
  List<Object?> get props => [
    sendCodeStatus,
    verifyCodeStatus,
    resetStatus,
    email,
    resetToken,
    errorMessage,
    step,
    resendCooldown,
  ];
}
