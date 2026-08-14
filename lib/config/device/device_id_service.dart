import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../secure_storage/secure_storage.dart';

@injectable
class DeviceIdService {
  DeviceIdService(this._secureStorage);

  final SecureStorage _secureStorage;

  Future<String> getDeviceId() async {
    final existingDeviceId = await _secureStorage.getDeviceId();

    if (existingDeviceId != null && existingDeviceId.isNotEmpty) {
      return existingDeviceId;
    }

    final newDeviceId = const Uuid().v4();

    await _secureStorage.saveDeviceId(newDeviceId);

    return newDeviceId;
  }
}