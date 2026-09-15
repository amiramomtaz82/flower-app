import 'package:flower_app/features/auth/data/models/login_response.dart';

import '../../models/user_dto.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);

  Future<String?> getToken();

  Future<void> saveRefreshToken(String token);

  Future<String?> getRefreshToken();

  Future<void> saveUser(UserDto user);

  Future<UserDto?> getUser();

  Future<void> clearAuthData();
  Future<void> saveNotificationsEnabled(bool isEnabled);
  Future<bool> getNotificationsEnabled();
}