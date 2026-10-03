import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/change_password_entity.dart';

part 'change_password_dto.g.dart';

@JsonSerializable()
class ChangePasswordRequestDto {
  @JsonKey(name: 'currentPassword')
  final String currentPassword;

  @JsonKey(name: 'newPassword')
  final String newPassword;

  @JsonKey(name: 'confirmNewPassword')
  final String confirmPassword;

  const ChangePasswordRequestDto({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ChangePasswordRequestDto.fromEntity(ChangePasswordParams entity) =>
      ChangePasswordRequestDto(
        currentPassword: entity.currentPassword,
        newPassword: entity.newPassword,
        confirmPassword: entity.confirmPassword,
      );

  factory ChangePasswordRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordRequestDtoToJson(this);
}
