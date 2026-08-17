import 'package:flower_app/features/auth/data/models/login_response.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(String token);

  Future<String?> getToken();

  Future<void> saveRefreshToken(String token);

  Future<String?> getRefreshToken();

  Future<void> saveUser(User user);

  Future<User?> getUser();

  Future<void> clearAuthData();
}