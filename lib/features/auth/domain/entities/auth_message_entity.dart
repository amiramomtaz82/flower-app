import 'package:equatable/equatable.dart';

class AuthMessageEntity extends Equatable {
  final String message;
  final String messageLocalized;

  const AuthMessageEntity({
    required this.message,
    required this.messageLocalized,
  });

  @override
  List<Object?> get props => [message, messageLocalized];

  @override
  String toString() =>
      'AuthMessageEntity(message: $message, messageLocalized: $messageLocalized)';
}
