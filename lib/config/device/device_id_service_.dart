abstract class DeviceIdService{

  Future<void> saveDeviceId(String deviceId);

  Future<String> getDeviceId();

}