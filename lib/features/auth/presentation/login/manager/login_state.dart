import 'package:equatable/equatable.dart';
import 'package:flower_app/features/auth/domain/entities/login_entity.dart';

import '../../../../../config/resource/rsource.dart';
import '../../../data/models/login_response.dart';

class LoginState extends Equatable {
  final String email;
  final String password;
  final bool isValid;
  final Resource<LoginEntity> loginResource;

  LoginState({
    this.email = '',
    this.password = '',
    this.isValid = false,
    Resource<LoginEntity>? loginResource,
  }) : loginResource = loginResource ?? Resource.initial();
  factory LoginState.initial() {
    return LoginState(
      loginResource: Resource.initial(),
    );
  }
  LoginState copyWith({
    String? email,
    String? password,
    bool? isValid,
    Resource<LoginEntity>? loginResource,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      loginResource: loginResource ?? this.loginResource,
    );
  }

  @override
  List<Object?> get props => [
    email,
    password,
    isValid,
    loginResource,
  ];
}