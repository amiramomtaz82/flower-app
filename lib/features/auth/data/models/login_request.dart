/// email : "customer@example.com"
/// password : "Password123"
/// deviceId : "device_abc123"
/// fcmToken : "fcm_token_xyz"

class LoginRequest {
  final String email;
  final String password;
  final String deviceId;
  final String? fcmToken;

  const LoginRequest({
    required this.email,
    required this.password,
    required this.deviceId,
    required this.fcmToken,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      email: json['email'],
      password: json['password'],
      deviceId: json['deviceId'],
      fcmToken: json['fcmToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'deviceId': deviceId,
      'fcmToken': fcmToken,
    };
  }
}