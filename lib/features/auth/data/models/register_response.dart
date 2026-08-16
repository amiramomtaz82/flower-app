import 'package:json_annotation/json_annotation.dart';

part 'register_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final AuthResponseData? data;
  final bool? isSuccess;
  final String? message;
  final String? messageLocalized;
  final int? statusCode;

  const AuthResponse({
    this.data,
    this.isSuccess,
    this.message,
    this.messageLocalized,
    this.statusCode,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class AuthResponseData {
  final String? id;
  final bool? isSuccess;

  const AuthResponseData({this.id, this.isSuccess});

  factory AuthResponseData.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseDataToJson(this);
}
