class LoginEntity {
  final String? accessToken;
  final String? refreshToken;
  final num? expiresIn;
  final String? role;
  final String? driverStatus;
  final UserEntity? user;

  const LoginEntity({
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.role,
    this.driverStatus,
    this.user,
  });
}

class UserEntity {
  final String? id;
  final String? email;
  final String? fullName;
  final String? role;
  final bool? isActive;
  final String? driverStatus;

  const UserEntity({
    this.id,
    this.email,
    this.fullName,
    this.role,
    this.isActive,
    this.driverStatus,
  });
}