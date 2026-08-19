import 'dart:convert';

import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/features/auth/data/data_source/local/auth_local_data_source.dart';
import 'package:flower_app/features/auth/data/models/login_response.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/secure_storage/secure_storage.dart';


@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorage _secureStorage;

  AuthLocalDataSourceImpl(this._secureStorage);

  static const String _accessTokenKey = AppStrings.accessToken;
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userKey = 'user';

  @override
  Future<void> saveToken(String token) {
    return _secureStorage.write(
      key: _accessTokenKey,
      value: token,
    );
  }

  @override
  Future<String?> getToken() {
    return _secureStorage.read(
      key: _accessTokenKey,
    );
  }

  @override
  Future<void> saveRefreshToken(String token) {
    return _secureStorage.write(
      key: _refreshTokenKey,
      value: token,
    );
  }

  @override
  Future<String?> getRefreshToken() {
    return _secureStorage.read(
      key: _refreshTokenKey,
    );
  }

  @override
  Future<void> saveUser(User user) {
    return _secureStorage.write(
      key: _userKey,
      value: jsonEncode(user.toJson()),
    );
  }

  @override
  Future<User?> getUser() async {
    final userJson = await _secureStorage.read(
      key: _userKey,
    );

    if (userJson == null) {
      return null;
    }

    return User.fromJson(
      jsonDecode(userJson),
    );
  }

  @override
  Future<void> clearAuthData() async {
    await _secureStorage.delete(
      key: _accessTokenKey,
    );

    await _secureStorage.delete(
      key: _refreshTokenKey,
    );

    await _secureStorage.delete(
      key: _userKey,
    );
  }
}