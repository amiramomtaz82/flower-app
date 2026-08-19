import 'dart:async';

import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/go_routes/routes_name.dart';
import 'package:flower_app/core/ui_action/ui_action.dart';
import 'package:flower_app/core/ui_action/ui_action_dispatcher.dart';
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
  final UiActionDispatcher _uiActionDispatcher;

  ForgetPasswordBloc(
    this._forgetPasswordUseCase,
    this._verifyOtpUseCase,
    this._resetPasswordUseCase,
    this._uiActionDispatcher,
  ) : super(ForgetPasswordState.initial()) {
    on<SendResetCodeEvent>(_sendResetCode);
    on<VerifyResetCodeEvent>(_verifyResetCode);
    on<OtpChangedEvent>(_otpChanged);
    on<ResetPasswordEvent>(_resetPassword);
    on<ResendCooldownTicked>(_resendCooldownTicked);
    on<BackToPreviousStepEvent>(_backToPreviousStep);
  }

  static const int resendCooldownSeconds = 30;

  Timer? _resendTimer;

  Future<void> _sendResetCode(
    SendResetCodeEvent event,
    Emitter<ForgetPasswordState> emit,
  ) async {
    if (state.isSendingCode) return;
    if (event.isResend && state.resendCooldown > 0) return;

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
            resendCooldown: resendCooldownSeconds,
            step: event.isResend ? null : ForgetPasswordStep.otp,
          ),
        );
        if (event.isResend) {
          _uiActionDispatcher.dispatch(
            ShowSnackBarAction.success(
              _backendMessage(data, AppStrings.codeSent),
            ),
          );
        }
        _startResendCooldown();
      case ErrorResponse(errMessage: final errMessage):
        emit(
          state.copyWith(
            sendCodeStatus: ForgetPasswordStatus.error,
            errorMessage: errMessage,
          ),
        );
        _uiActionDispatcher.dispatch(ShowSnackBarAction.error(errMessage));
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
            step: ForgetPasswordStep.resetPassword,
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
          step: ForgetPasswordStep.otp,
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
          ),
        );
        _uiActionDispatcher.dispatch(
          const NavigateAction(AppRoutes.login, replace: true),
        );
      case ErrorResponse(:final errMessage):
        emit(
          state.copyWith(
            resetStatus: ForgetPasswordStatus.error,
            errorMessage: errMessage,
          ),
        );
        _uiActionDispatcher.dispatch(ShowSnackBarAction.error(errMessage));
    }
  }

  void _backToPreviousStep(
    BackToPreviousStepEvent event,
    Emitter<ForgetPasswordState> emit,
  ) {
    if (state.step == ForgetPasswordStep.email) return;
    emit(
      state.copyWith(step: ForgetPasswordStep.values[state.step.index - 1]),
    );
  }

  void _resendCooldownTicked(
    ResendCooldownTicked event,
    Emitter<ForgetPasswordState> emit,
  ) {
    emit(state.copyWith(resendCooldown: event.secondsLeft));
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final secondsLeft = state.resendCooldown - 1;
      add(ResendCooldownTicked(secondsLeft));
      if (secondsLeft <= 0) timer.cancel();
    });
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    return super.close();
  }

  String _backendMessage(AuthMessageEntity message, String fallbackKey) =>
      message.messageLocalized.isNotEmpty
      ? message.messageLocalized
      : fallbackKey;
}
