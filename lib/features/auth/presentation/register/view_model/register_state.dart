import 'package:equatable/equatable.dart';
import 'package:flower_app/features/auth/domain/entities/auth_entity.dart';

class RegisterState extends Equatable {
  final bool isLoading;
  final RegisterEntity? data;
  final String errMessage;

  const RegisterState({
    this.isLoading = false,
    this.data,
    this.errMessage = '',
  });

  RegisterState copyWith({
    bool? isLoading,
    RegisterEntity? data,
    String? errMessage,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
      errMessage: errMessage ?? this.errMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, data, errMessage];
}
