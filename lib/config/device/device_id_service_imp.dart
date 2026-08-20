import 'package:flower_app/config/device/device_id_service_.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../secure_storage/secure_storage.dart';

@LazySingleton(as:DeviceIdService)

class DeviceIdServiceImp extends DeviceIdService{
  final SecureStorage _secureStorage;

  DeviceIdServiceImp(this._secureStorage);

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
      key: AppStrings.deviceId,
    );

    if (deviceId != null && deviceId.isNotEmpty) {
      return deviceId;
    }

    final newDeviceId = const Uuid().v4();

    await _secureStorage.write(
      key: AppStrings.deviceId,
      value: newDeviceId,
    );

    return newDeviceId;
  }

}