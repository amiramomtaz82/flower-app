import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/change_password_entity.dart';

part 'change_password_dto.g.dart';

@JsonSerializable()
class ChangePasswordDto {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordDto({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  factory ChangePasswordDto.fromEntity(ChangePasswordEntity entity) =>
      ChangePasswordDto(
        currentPassword: entity.currentPassword,
        newPassword: entity.newPassword,
        confirmPassword: entity.confirmPassword,
      );

  factory ChangePasswordDto.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordDtoToJson(this);
}
