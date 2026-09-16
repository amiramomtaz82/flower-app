class UpdateFcmTokenRequest {
  final String deviceId;

  final String fcmToken;

  const UpdateFcmTokenRequest({
    required this.deviceId,

    required this.fcmToken,
  });

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,

    'fcmToken': fcmToken,
  };
}