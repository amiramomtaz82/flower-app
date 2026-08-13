/// accessToken : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
/// refreshToken : "d9a8f7c6b5a4..."
/// expiresIn : 900
/// role : "Customer"
/// driverStatus : "Approved"
/// user : {"id":"018f23a4-1234-7000-8000-000000000001","email":"customer@example.com","fullName":"Ahmed Hassan","role":"Customer","isActive":true,"driverStatus":null}

class LoginResponse {
  LoginResponse({
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.role,
    this.driverStatus,
    this.user,});

  LoginResponse.fromJson(dynamic json) {
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    expiresIn = json['expiresIn'];
    role = json['role'];
    driverStatus = json['driverStatus'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
  String? accessToken;
  String? refreshToken;
  num? expiresIn;
  String? role;
  String? driverStatus;
  User? user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['accessToken'] = accessToken;
    map['refreshToken'] = refreshToken;
    map['expiresIn'] = expiresIn;
    map['role'] = role;
    map['driverStatus'] = driverStatus;
    if (user != null) {
      map['user'] = user?.toJson();
    }
    return map;
  }

}

/// id : "018f23a4-1234-7000-8000-000000000001"
/// email : "customer@example.com"
/// fullName : "Ahmed Hassan"
/// role : "Customer"
/// isActive : true
/// driverStatus : null

class User {
  User({
    this.id,
    this.email,
    this.fullName,
    this.role,
    this.isActive,
    this.driverStatus,});

  User.fromJson(dynamic json) {
    id = json['id'];
    email = json['email'];
    fullName = json['fullName'];
    role = json['role'];
    isActive = json['isActive'];
    driverStatus = json['driverStatus'];
  }
  String? id;
  String? email;
  String? fullName;
  String? role;
  bool? isActive;
  dynamic driverStatus;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['email'] = email;
    map['fullName'] = fullName;
    map['role'] = role;
    map['isActive'] = isActive;
    map['driverStatus'] = driverStatus;
    return map;
  }

}