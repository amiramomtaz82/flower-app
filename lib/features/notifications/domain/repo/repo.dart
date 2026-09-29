abstract interface class NotificationRepo {
  Future<void> syncFcmToken();
  Future<void> updateFcmToken({
    required String fcmToken,
  });
  Future<void> setDeviceNotifications({required bool enabled});
  void dispose();
}