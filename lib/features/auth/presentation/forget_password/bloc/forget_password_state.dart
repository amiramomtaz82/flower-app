import 'package:equatable/equatable.dart';
import 'package:flower_app/features/auth/domain/entities/reset_token_entity.dart';

enum ForgetPasswordStatus { initial, loading, success, error }

enum ForgetPasswordUiActionType {
  none,
  showError,
  showSuccess,
  goToOtp,
  goToResetPassword,
  goToLogin,
}

class ForgetPasswordUiAction {
  final ForgetPasswordUiActionType type;

  final String? message;

  const ForgetPasswordUiAction._(this.type, {this.message});

  const ForgetPasswordUiAction.none() : this._(ForgetPasswordUiActionType.none);
  const ForgetPasswordUiAction.error(String message)
    : this._(ForgetPasswordUiActionType.showError, message: message);
  const ForgetPasswordUiAction.success(String message)
    : this._(ForgetPasswordUiActionType.showSuccess, message: message);
  const ForgetPasswordUiAction.goToOtp()
    : this._(ForgetPasswordUiActionType.goToOtp);
  const ForgetPasswordUiAction.goToResetPassword()
    : this._(ForgetPasswordUiActionType.goToResetPassword);
  const ForgetPasswordUiAction.goToLogin()
    : this._(ForgetPasswordUiActionType.goToLogin);
}

class ForgetPasswordState extends Equatable {
  final ForgetPasswordStatus sendCodeStatus;
  final ForgetPasswordStatus verifyCodeStatus;
  final ForgetPasswordStatus resetStatus;

  final String email;

  final ResetToken? resetToken;

  final String? errorMessage;
  final ForgetPasswordUiAction uiAction;

  const ForgetPasswordState({
    required this.sendCodeStatus,
    required this.verifyCodeStatus,
    required this.resetStatus,
    required this.email,
    required this.resetToken,
    required this.errorMessage,
    required this.uiAction,
  });

  factory ForgetPasswordState.initial() => const ForgetPasswordState(
    sendCodeStatus: ForgetPasswordStatus.initial,
    verifyCodeStatus: ForgetPasswordStatus.initial,
    resetStatus: ForgetPasswordStatus.initial,
    email: '',
    resetToken: null,
    errorMessage: null,
    uiAction: ForgetPasswordUiAction.none(),
  );

  bool get isSendingCode => sendCodeStatus == ForgetPasswordStatus.loading;
  bool get isVerifyingCode => verifyCodeStatus == ForgetPasswordStatus.loading;
  bool get isResettingPassword => resetStatus == ForgetPasswordStatus.loading;

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
    ForgetPasswordUiAction? uiAction,
  }) => ForgetPasswordState(
    sendCodeStatus: sendCodeStatus ?? this.sendCodeStatus,
    verifyCodeStatus: verifyCodeStatus ?? this.verifyCodeStatus,
    resetStatus: resetStatus ?? this.resetStatus,
    email: email ?? this.email,
    resetToken: clearResetToken ? null : (resetToken ?? this.resetToken),
    errorMessage: clearErrorMessage
        ? null
        : (errorMessage ?? this.errorMessage),
    uiAction: uiAction ?? this.uiAction,
  );

  @override
  List<Object?> get props => [
    sendCodeStatus,
    verifyCodeStatus,
    resetStatus,
    email,
    resetToken,
    errorMessage,
    uiAction,
  ];
}
