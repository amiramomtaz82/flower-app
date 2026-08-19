


import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SecureStorage {
  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  Future<void> write({
    required String key,
    required String value,
  }) async {
    await _storage.write(
      key: key,
      value: value,
    );
  }

  Future<String?> read({
    required String key,
  }) async {
    return _storage.read(key: key);
  }

  Future<void> delete({
    required String key,
  }) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}







// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:injectable/injectable.dart';
//
//
// @lazySingleton
// class SecureStorage {
//   static const FlutterSecureStorage _storage = FlutterSecureStorage();
//
//   Future<void> saveAccessToken(String token) async {
//     await _storage.write(key: 'accessToken', value: token);
//   }
//
//   Future<String?> getAccessToken() async {
//     return await _storage.read(key: 'accessToken');
//   }
//
//   Future<void> deleteAccessToken() async {
//     await _storage.delete(key: 'accessToken');
//   }
//
//   Future<void> clear() async {
//     await _storage.deleteAll();
//   }
//
//
//   Future<void> saveRefreshToken(String token) async {
//     await _storage.write(
//       key: "refreshToken",
//       value: token,
//     );
//   }
//
//
//
//
//
//   Future<String?> getRefreshToken() async {
//     return await _storage.read(
//       key: "refreshToken",
//     );
//   }
//
//
//
//
//
//   static const String _deviceIdKey = 'device_id';
//
//   Future<void> saveDeviceId(String deviceId) async {
//     await _storage.write(
//       key: _deviceIdKey,
//       value: deviceId,
//     );
//   }
//
//   Future<String?> getDeviceId() async {
//     return await _storage.read(
//       key: _deviceIdKey,
//     );
//   }
// }
