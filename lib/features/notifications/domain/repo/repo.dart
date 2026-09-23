abstract interface class NotificationRepo {
  Future<void> syncFcmToken();
  Future<void> updateFcmToken({
    required String fcmToken,
  });
  void dispose();
}