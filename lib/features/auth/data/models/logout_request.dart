/// deviceId : "device_abc123"
library;

class LogoutRequest {
  final String deviceId;

  const LogoutRequest({
    required this.deviceId,
  });

  factory LogoutRequest.fromJson(Map<String, dynamic> json) {
    return LogoutRequest(
      deviceId: json['deviceId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
    };
  }
}