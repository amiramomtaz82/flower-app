class UpdateFcmTokenRequest {
  final String deviceId;
  final String userId;
  final String fcmToken;

  const UpdateFcmTokenRequest({
    required this.deviceId,
    required this.userId,
    required this.fcmToken,
  });

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'userId': userId,
    'fcmToken': fcmToken,
  };
}