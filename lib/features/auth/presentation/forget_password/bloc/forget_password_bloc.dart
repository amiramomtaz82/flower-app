import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/features/auth/domain/entities/auth_message_entity.dart';
import 'package:flower_app/features/auth/domain/use_cases/forget_password_use_case.dart';
import 'package:flower_app/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:flower_app/features/auth/domain/use_cases/verify_otp_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'forget_password_event.dart';
import 'forget_password_state.dart';

@injectable
class ForgetPasswordBloc
    extends Bloc<ForgetPasswordEvent, ForgetPasswordState> {
  final ForgetPasswordUseCase _forgetPasswordUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  ForgetPasswordBloc(
    this._forgetPasswordUseCase,
    this._verifyOtpUseCase,
    this._resetPasswordUseCase,
  ) : super(ForgetPasswordState.initial()) {
    on<SendResetCodeEvent>(_sendResetCode);
    on<VerifyResetCodeEvent>(_verifyResetCode);
    on<OtpChangedEvent>(_otpChanged);
    on<ResetPasswordEvent>(_resetPassword);
    on<ClearUiActionEvent>(_clearUiAction);
  }

  Future<void> _sendResetCode(
    SendResetCodeEvent event,
    Emitter<ForgetPasswordState> emit,
  ) async {
    if (state.isSendingCode) return;

    emit(
      state.copyWith(
        sendCodeStatus: ForgetPasswordStatus.loading,
        verifyCodeStatus: ForgetPasswordStatus.initial,
        email: event.email,
        clearErrorMessage: true,
        clearResetToken: true,
      ),
    );

    final result = await _forgetPasswordUseCase(email: event.email);

    switch (result) {
      case SuccessResponse(data: final data):
        emit(
          state.copyWith(
            sendCodeStatus: ForgetPasswordStatus.success,
            uiAction: event.isResend
                ? ForgetPasswordUiAction.success(
                    _backendMessage(data, AppStrings.codeSent),
                  )
                : const ForgetPasswordUiAction.goToOtp(),
          ),
        );
      case ErrorResponse(errMessage: final errMessage):
        // final err = result.errMessage;
        emit(
          state.copyWith(
            sendCodeStatus: ForgetPasswordStatus.error,
            errorMessage: errMessage,
            uiAction: ForgetPasswordUiAction.error(errMessage),
          ),
        );
    }
  }

  Future<void> _verifyResetCode(
    VerifyResetCodeEvent event,
    Emitter<ForgetPasswordState> emit,
  ) async {
    if (state.isVerifyingCode) return;

    emit(
      state.copyWith(
        verifyCodeStatus: ForgetPasswordStatus.loading,
        clearErrorMessage: true,
      ),
    );

    final result = await _verifyOtpUseCase(
      email: state.email,
      otpCode: event.otp,
    );

    switch (result) {
      case SuccessResponse(:final data):
        emit(
          state.copyWith(
            verifyCodeStatus: ForgetPasswordStatus.success,
            resetToken: data,
            uiAction: const ForgetPasswordUiAction.goToResetPassword(),
          ),
        );
      case ErrorResponse(errMessage: final errMessage):
        // The OTP screen shows this one inline, so no snackbar action.
        emit(
          state.copyWith(
            verifyCodeStatus: ForgetPasswordStatus.error,
            errorMessage: errMessage,
          ),
        );
    }
  }

  void _otpChanged(OtpChangedEvent event, Emitter<ForgetPasswordState> emit) {
    if (state.verifyCodeStatus != ForgetPasswordStatus.error) return;
    emit(
      state.copyWith(
        verifyCodeStatus: ForgetPasswordStatus.initial,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> _resetPassword(
    ResetPasswordEvent event,
    Emitter<ForgetPasswordState> emit,
  ) async {
    if (state.isResettingPassword) return;

    final resetToken = state.resetToken;

    if (resetToken == null || resetToken.isExpired) {
      emit(
        state.copyWith(
          resetStatus: ForgetPasswordStatus.initial,
          verifyCodeStatus: ForgetPasswordStatus.error,
          errorMessage: AppStrings.resetSessionExpired,
          clearResetToken: true,
          uiAction: const ForgetPasswordUiAction.goToOtp(),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        resetStatus: ForgetPasswordStatus.loading,
        clearErrorMessage: true,
      ),
    );

    final result = await _resetPasswordUseCase(
      resetToken: resetToken.token,
      newPassword: event.newPassword,
      confirmNewPassword: event.confirmNewPassword,
    );

    switch (result) {
      case SuccessResponse():
        emit(
          state.copyWith(
            resetStatus: ForgetPasswordStatus.success,
            clearResetToken: true,
            uiAction: const ForgetPasswordUiAction.goToLogin(),
          ),
        );
      case ErrorResponse(:final errMessage):
        emit(
          state.copyWith(
            resetStatus: ForgetPasswordStatus.error,
            errorMessage: errMessage,
            uiAction: ForgetPasswordUiAction.error(errMessage),
          ),
        );
    }
  }

  void _clearUiAction(
    ClearUiActionEvent event,
    Emitter<ForgetPasswordState> emit,
  ) {
    emit(state.copyWith(uiAction: const ForgetPasswordUiAction.none()));
  }

  String _backendMessage(AuthMessageEntity message, String fallbackKey) =>
      message.messageLocalized.isNotEmpty
      ? message.messageLocalized
      : fallbackKey;
}
