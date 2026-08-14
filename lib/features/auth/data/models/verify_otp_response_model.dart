import 'package:json_annotation/json_annotation.dart';
import 'package:flower_app/features/auth/domain/entities/reset_token_entity.dart';

part 'verify_otp_response_model.g.dart';

@JsonSerializable()
class VerifyOtpResponseVm {
  final String resetToken;
  final DateTime expiresAt;

  const VerifyOtpResponseVm({
    required this.resetToken,
    required this.expiresAt,
  });

  factory VerifyOtpResponseVm.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpResponseVmFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOtpResponseVmToJson(this);

  ResetToken toEntity() => ResetToken(token: resetToken, expiresAt: expiresAt);
}

@JsonSerializable()
class VerifyOtpResponseModel {
  final VerifyOtpResponseVm data;

  const VerifyOtpResponseModel({required this.data});

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyOtpResponseModelToJson(this);
}
