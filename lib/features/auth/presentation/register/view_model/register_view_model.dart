import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/network/base_response.dart';
import 'package:flower_app/features/auth/domain/entities/auth_entity.dart';
import 'package:flower_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_event.dart';
import 'package:flower_app/features/auth/presentation/register/view_model/register_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class RegisterViewModel extends Cubit<RegisterState> {
  final RegisterUseCase _registerUseCase;

  RegisterViewModel(this._registerUseCase)
      : super(RegisterState(status: Resource.initial()));

  void doEvent(RegisterEvent event) {
    switch (event) {
      case DoRegister():
        _register(event);
      case SelectGender():
        emit(state.copyWith(selectedGender: event.gender));
      case UpdateField():
        emit(state.copyWith(
          firstName: event.firstName,
          lastName: event.lastName,
          email: event.email,
          password: event.password,
          confirmPassword: event.confirmPassword,
          phoneNumber: event.phoneNumber,
        ));
    }
  }

  Future<void> _register(DoRegister event) async {
    emit(state.copyWith(status: Resource.loading()));

    final response = await _registerUseCase(event.params);

    switch (response) {
      case SuccessResponse<RegisterEntity>():
        emit(state.copyWith(status: Resource.success(response.data)));
      case ErrorResponse<RegisterEntity>():
        emit(state.copyWith(status: Resource.error(response.errMessage)));
    }
  }
}
