/// email : "customer@example.com"
/// password : "Password123"
/// deviceId : "device_abc123"
/// fcmToken : "fcm_token_xyz"

class LoginRequest {
  LoginRequest({
    this.email,
    this.password,
    this.deviceId,
    this.fcmToken,});

  LoginRequest.fromJson(dynamic json) {
    email = json['email'];
    password = json['password'];
    deviceId = json['deviceId'];
    fcmToken = json['fcmToken'];
  }
  String? email;
  String? password;
  String? deviceId;
  String? fcmToken;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['email'] = email;
    map['password'] = password;
    map['deviceId'] = deviceId;
    map['fcmToken'] = fcmToken;
    return map;
  }

}