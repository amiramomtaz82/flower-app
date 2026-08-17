import 'package:flower_app/features/auth/domain/entities/gender.dart';
import 'package:flower_app/features/auth/domain/entities/register_params.dart';

sealed class RegisterEvent {}

class DoRegister extends RegisterEvent {
  final RegisterParams params;

  DoRegister(this.params);
}

class SelectGender extends RegisterEvent {
  final Gender gender;

  SelectGender(this.gender);
}

class UpdateField extends RegisterEvent {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;
  final String? confirmPassword;
  final String? phoneNumber;

  UpdateField({
    this.firstName,
    this.lastName,
    this.email,
    this.password,
    this.confirmPassword,
    this.phoneNumber,
  });
}