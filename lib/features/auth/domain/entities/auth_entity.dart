import 'package:equatable/equatable.dart';

class RegisterEntity extends Equatable {
  final String? message;
  final String? messageLocalized;

  const RegisterEntity({
    this.message,
    this.messageLocalized,
  });

  @override
  List<Object?> get props => [message, messageLocalized];
}