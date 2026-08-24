import 'package:equatable/equatable.dart';
import 'package:flower_app/features/auth/domain/entities/login_entity.dart';

import '../../../../../config/resource/rsource.dart';

class LoginState extends Equatable {
  final String email;
  final String password;
  final bool isValid;
  final bool obscurePassword;
  final Resource<LoginEntity> loginResource;

  LoginState({
    this.obscurePassword = true,
    this.email = '',
    this.password = '',
    this.isValid = false,
    Resource<LoginEntity>? loginResource,
  }) : loginResource = loginResource ?? Resource.initial();
  factory LoginState.initial() {
    return LoginState(loginResource: Resource.initial());
  }
  LoginState copyWith({
    String? email,
    String? password,
    bool? isValid,
    bool? obscurePassword,
    Resource<LoginEntity>? loginResource,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      loginResource: loginResource ?? this.loginResource,
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    isValid,
    loginResource,
    obscurePassword,
  ];
}
