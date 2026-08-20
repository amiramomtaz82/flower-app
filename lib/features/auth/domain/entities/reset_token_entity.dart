import 'package:equatable/equatable.dart';

class ResetToken extends Equatable {
  final String token;
  final DateTime expiresAt;

  const ResetToken({required this.token, required this.expiresAt});
  @override
  List<Object?> get props => [token, expiresAt];
  // Check if the token is expired as of the given time
  bool isExpired(DateTime now) => now.isAfter(expiresAt);
}
