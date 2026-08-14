import 'package:flower_app/config/secure_storage/secure_storage.dart';
import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:flower_app/features/auth/data/models/login_response.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/login_response.dart';

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorage _secureStorage;


  AuthLocalDataSourceImpl(this._secureStorage);

  @override
  Future<void> saveToken(String token) => _secureStorage.saveAccessToken(token);

  @override
  Future<String?> getToken() => _secureStorage.getAccessToken();

  @override
  Future<void> clearToken() => _secureStorage.deleteAccessToken();

  @override
  Future<void> clearAuthData() =>_secureStorage.clearAuthData();


  @override
  Future<String?> getRefreshToken() => _secureStorage.getRefreshToken();



  @override
  Future<User?> getUser() =>_secureStorage.getUser();



  @override
  Future<void> saveRefreshToken(String token) =>_secureStorage.saveRefreshToken(token);

  @override
  Future<void> saveUser(User user) =>_secureStorage.saveUser(user);
}
