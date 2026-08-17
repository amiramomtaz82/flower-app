import 'package:equatable/equatable.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/features/auth/domain/entities/auth_entity.dart';
import 'package:flower_app/features/auth/domain/entities/gender.dart';

class RegisterState extends Equatable {
  final Resource<RegisterEntity> status;
  final Gender selectedGender;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String confirmPassword;
  final String phoneNumber;

  const RegisterState({
    required this.status,
    this.selectedGender = Gender.female,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.phoneNumber = '',
  });

  RegisterState copyWith({
    Resource<RegisterEntity>? status,
    Gender? selectedGender,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? confirmPassword,
    String? phoneNumber,
  }) {
    return RegisterState(
      status: status ?? this.status,
      selectedGender: selectedGender ?? this.selectedGender,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedGender,
        firstName,
        lastName,
        email,
        password,
        confirmPassword,
        phoneNumber,
      ];
}
