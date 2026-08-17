import 'package:equatable/equatable.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/features/auth/domain/entities/auth_entity.dart';
import 'package:flower_app/features/auth/domain/entities/gender.dart';

class RegisterState extends Equatable {
  final Resource<RegisterEntity> status;
  final Gender selectedGender;

  const RegisterState({
    required this.status,
    this.selectedGender = Gender.female,
  });

  RegisterState copyWith({
    Resource<RegisterEntity>? status,
    Gender? selectedGender,
  }) {
    return RegisterState(
      status: status ?? this.status,
      selectedGender: selectedGender ?? this.selectedGender,
    );
  }

  @override
  List<Object?> get props => [status, selectedGender];
}
