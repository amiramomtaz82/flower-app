import 'package:json_annotation/json_annotation.dart';
import 'package:flower_app/features/auth/domain/entities/reset_token_entity.dart';

part 'verify_otp_response_model.g.dart';

@JsonSerializable()
class VerifyOtpResponseData {
  final String resetToken;
  final DateTime expiresAt;

  const VerifyOtpResponseData({
    required this.resetToken,
    required this.expiresAt,
  });

  factory VerifyOtpResponseData.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOtpResponseDataToJson(this);

  ResetToken toEntity() => ResetToken(token: resetToken, expiresAt: expiresAt);
}

@JsonSerializable()
class VerifyOtpResponseModel {
  final VerifyOtpResponseData data;

  const VerifyOtpResponseModel({required this.data});

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOtpResponseModelToJson(this);
}
