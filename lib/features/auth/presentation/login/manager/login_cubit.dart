import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../config/base_response/base_response.dart';

import '../../../../../config/resource/rsource.dart';
import '../../../../../core/validation/validation.dart';
import '../../../domain/entities/login_entity.dart';
import '../../../domain/use_cases/login_use_case.dart';
import 'login_events.dart';
import 'login_state.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;

  LoginCubit(this._loginUseCase)
      : super(LoginState.initial());

  Future<void> doEvents(LoginEvent event) async {
    switch (event) {
      case EmailChanged():
        _onEmailChanged(event.email);

      case PasswordChanged():
        _onPasswordChanged(event.password);

      case LoginSubmitted():
        await _login();

      case PasswordVisibilityChanged():
        _onPasswordVisibilityChanged();
    }
  }

  void _onPasswordVisibilityChanged() {
    emit(
      state.copyWith(
        obscurePassword: !state.obscurePassword,
      ),
    );
  }

  void _onEmailChanged(String email) {
    emit(
      state.copyWith(
        email: email,
        isValid: _isFormValid(
          email,
          state.password,
        ),
      ),
    );
  }

  void _onPasswordChanged(String password) {
    emit(
      state.copyWith(
        password: password,
        isValid: _isFormValid(
          state.email,
          password,
        ),
      ),
    );
  }

  bool _isFormValid(String email, String password) {
    final emailError = Validation.validateEmail(email);
    final passwordError = Validation.validatePassword(password);

    return emailError == null && passwordError == null;
  }

  Future<void> _login() async {
    if (!state.isValid) {
      emit(
        state.copyWith(
          loginResource: Resource.error(
            AppStrings.pleaseFill,
          ),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        loginResource: Resource.loading(),
      ),
    );

    final result = await _loginUseCase(
      email: state.email,
      password: state.password,
    );

    switch (result) {
      case SuccessResponse<LoginEntity>():
        emit(
          state.copyWith(
            loginResource: Resource.success(result.data),
          ),
        );

      case ErrorResponse<LoginEntity>():
        emit(
          state.copyWith(
            loginResource: Resource.error(result.errMessage),
          ),
        );
    }
  }
}