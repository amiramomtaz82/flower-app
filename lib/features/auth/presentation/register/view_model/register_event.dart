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