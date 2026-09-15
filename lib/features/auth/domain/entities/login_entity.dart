import 'package:equatable/equatable.dart';
import 'user_entity.dart';

class LoginEntity extends Equatable {
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final String? driverStatus;
  final UserEntity? user;
  final bool notificationsEnabled;

  const LoginEntity({
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.driverStatus,
    this.user,
    this.notificationsEnabled = true,
  });

  @override
  List<Object?> get props => [
    accessToken,
    refreshToken,
    expiresIn,
    driverStatus,
    user,
    notificationsEnabled,
  ];
}