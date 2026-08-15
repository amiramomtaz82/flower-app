abstract class ForgetPasswordEvent {}

class SendResetCodeEvent extends ForgetPasswordEvent {
  final String email;
  final bool isResend;
  SendResetCodeEvent(this.email, {this.isResend = false});
}

class VerifyResetCodeEvent extends ForgetPasswordEvent {
  final String otp;
  VerifyResetCodeEvent(this.otp);
}

class OtpChangedEvent extends ForgetPasswordEvent {}

class ResetPasswordEvent extends ForgetPasswordEvent {
  final String newPassword;
  final String confirmNewPassword;
  ResetPasswordEvent(this.newPassword, this.confirmNewPassword);
}

class ClearUiActionEvent extends ForgetPasswordEvent {}
