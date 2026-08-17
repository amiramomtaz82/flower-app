import 'package:equatable/equatable.dart';

import 'gender.dart';

class RegisterParams extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String confirmPassword;
  final String phoneNumber;
  final Gender gender;

  const RegisterParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phoneNumber,
    required this.gender,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        password,
        confirmPassword,
        phoneNumber,
        gender,
      ];
}
