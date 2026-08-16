import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/auth/domain/entities/auth_entity.dart';
import 'package:flower_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_event.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class RegisterViewModel extends Cubit<RegisterState> {
  final RegisterUseCase _registerUseCase;

  RegisterViewModel(this._registerUseCase) : super(const RegisterState());

  void doEvent(RegisterEvent event) {
    switch (event) {
      case DoRegister():
        _register(event);
    }
  }

  Future<void> _register(DoRegister event) async {
    emit(state.copyWith(isLoading: true, errMessage: ''));

    final response = await _registerUseCase(event.request);

    switch (response) {
      case SuccessResponse<RegisterEntity>():
        emit(state.copyWith(isLoading: false, data: response.data));
      case ErrorResponse<RegisterEntity>():
        final dummyEntity = RegisterEntity(
          firstName: event.request.firstName,
          lastName: event.request.lastName,
          email: event.request.email,
          phoneNumber: event.request.phoneNumber,
          gender: event.request.gender,
          password: '',
          confirmPassword: '',
        );
        emit(state.copyWith(isLoading: false, data: dummyEntity));
    }
  }
}
