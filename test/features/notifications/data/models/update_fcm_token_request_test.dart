import 'package:flower_app/features/notifications/data/models/update_fcm_token.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateFcmTokenRequest', () {
    const tToken = 'test-fcm-token-xyz';
    const tPlatform = 'Android';

    const tRequest = UpdateFcmTokenRequest(
      token: tToken,
      platform: tPlatform,
    );

    test('should return a valid JSON map containing token and platform', () {
      final json = tRequest.toJson();

      expect(json, {
        'token': tToken,
        'platform': tPlatform,
      });
    });
  });
}
