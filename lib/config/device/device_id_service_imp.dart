import 'package:flower_app/config/device/device_id_service_.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../secure_storage/secure_storage.dart';

@LazySingleton(as: DeviceIdService)
class DeviceIdServiceImp extends DeviceIdService {
  final SecureStorage _secureStorage;
  final Uuid _uuid; // 👈 1. Injected dependency

  DeviceIdServiceImp(
      this._secureStorage,
      this._uuid, // 👈 2. Injected in constructor
      );

  static const String _deviceIdKey = AppStrings.deviceId;

  @override
  Future<void> saveDeviceId(String deviceId) {
    return _secureStorage.write(
      key: _deviceIdKey,
      value: deviceId,
    );
  }

  @override
  Future<String> getDeviceId() async {
    final deviceId = await _secureStorage.read(
      key: _deviceIdKey,
    );

    if (deviceId != null && deviceId.isNotEmpty) {
      return deviceId;
    }

    // 👈 3. Uses the injected instance
    final newDeviceId = _uuid.v4();

    await _secureStorage.write(
      key: _deviceIdKey,
      value: newDeviceId,
    );

    return newDeviceId;
  }
}