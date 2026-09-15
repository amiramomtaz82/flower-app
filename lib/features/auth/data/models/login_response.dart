import 'package:flower_app/features/auth/data/models/user_dto.dart';

import '../../domain/entities/login_entity.dart';

class LoginResponse {
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final String? driverStatus;
  final UserDto? user;
  final bool notificationsEnabled; // Non-nullable with safe default

  LoginResponse({
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.driverStatus,
    this.user,
    this.notificationsEnabled = true,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      expiresIn: json['expiresIn'] as int?,
      driverStatus: json['driverStatus'] as String?,
      user: json['user'] != null ? UserDto.fromJson(json['user'] as Map<String, dynamic>) : null,
      // Safely check root, nested device object, or fallback to true per spec:
      notificationsEnabled: (json['notificationsEnabled'] ??
          json['device']?['notificationsEnabled'] ??
          true) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'driverStatus': driverStatus,
      if (user != null) 'user': user!.toJson(),
      'notificationsEnabled': notificationsEnabled,
    };
  }

  LoginEntity toEntity() {
    return LoginEntity(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user?.toEntity(),
      notificationsEnabled: notificationsEnabled,
    );
  }
}