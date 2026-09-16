


abstract class NotificationRepo {
  Future<void> updateFcmToken({
    required String deviceId,

    required String fcmToken,
  });
}

