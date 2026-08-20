
import '../../models/login_response.dart';

abstract interface class AuthLocalDataSource {


  Future<void> saveToken(String token);

  Future<void> saveRefreshToken(String token);

  Future<void> saveUser(User user);

  Future<String?> getToken();



  Future<String?> getRefreshToken();



  Future<User?> getUser();


  Future<void> clearToken();

  Future<void> clearAuthData();



}


