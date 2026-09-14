import 'package:flower_app/features/profile/domain/entities/update_profile_entity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'update_profile_dto.g.dart';

@JsonSerializable()
class UpdateProfileDto {
  @JsonKey(name: "fullName")
  final String fullName;
  @JsonKey(name: "email")
  final String email;
  @JsonKey(name: "phoneNumber")
  final String phoneNumber;
  @JsonKey(name: "gender")
  final String gender;
  @JsonKey(name: "photoUrl")
  final String photoUrl;

  UpdateProfileDto({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    required this.photoUrl,
  });

  factory UpdateProfileDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileDtoToJson(this);

  // Convert UpdateProfileEntity to UpdateProfileDto
  UpdateProfileDto.fromEntity(UpdateProfileEntity entity)
    : fullName = entity.fullName,
      email = entity.email,
      phoneNumber = entity.phoneNumber,
      gender = entity.gender,
      photoUrl = entity.photoUrl;
}
