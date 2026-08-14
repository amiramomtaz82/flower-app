import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/data/models/login_response.dart';
import 'dart:convert';
@lazySingleton
class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: 'accessToken', value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: 'accessToken');
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }


  Future<void> saveRefreshToken(String token) async {
    await _storage.write(
      key: "refreshToken",
      value: token,
    );
  }
    Future<void> saveUser(User user) async {
      await _storage.write(
        key: "user",
        value: jsonEncode(user.toJson()),
      );
    }





  Future<String?> getRefreshToken() async {
    return await _storage.read(
      key: "refreshToken",
    );
  }


  Future<User?> getUser() async {
    final userJson = await _storage.read(
      key:"user",
    );

    if (userJson == null) {
      return null;
    }

    return User.fromJson(jsonDecode(userJson));
  }


  Future<void> clearAuthData() async {
    await _storage.delete(key: "accessToken");
    await _storage.delete(key:"refreshToken");
    await _storage.delete(key: "user");
  }

  static const String _deviceIdKey = 'device_id';

  Future<void> saveDeviceId(String deviceId) async {
    await _storage.write(
      key: _deviceIdKey,
      value: deviceId,
    );
  }

  Future<String?> getDeviceId() async {
    return await _storage.read(
      key: _deviceIdKey,
    );
  }
}
