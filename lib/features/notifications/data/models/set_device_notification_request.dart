class SetDeviceNotificationsRequest {
  final String deviceId;
  final bool enabled;

  const SetDeviceNotificationsRequest({
    required this.deviceId,
    required this.enabled,
  });

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'enabled': enabled,
  };
}