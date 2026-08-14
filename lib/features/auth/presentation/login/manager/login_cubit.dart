import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../config/base_response/base_response.dart';

import '../../../../../config/resource/rsource.dart';
import '../../../data/models/login_request.dart';
import '../../../domain/entities/login_entity.dart';
import '../../../domain/use_cases/login_use_case.dart';
import 'login_events.dart';
import 'login_state.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;

  LoginCubit(this._loginUseCase)
      : super(LoginState.initial());

  void doEvents(LoginEvent event) {
    switch (event) {
      case EmailChanged():
        _onEmailChanged(event.email);

      case PasswordChanged():
        _onPasswordChanged(event.password);

      case LoginSubmitted():
        _login();
    }
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
    return email.isNotEmpty && password.isNotEmpty;
  }

  Future<void> _login() async {
    if (!state.isValid) return;

    emit(
      state.copyWith(
        loginResource: Resource.loading(),
      ),
    );

    final request = LoginRequest(
      email: state.email,
      password: state.password,
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