import 'package:flower_app/features/profile/domain/entities/update_profile_entity.dart';

class UpdateProfileRequestDto {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String gender;
  final String? photoPath;

  UpdateProfileRequestDto({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    this.photoPath,
  });

  // Convert UpdateProfileEntity to UpdateProfileDto
  UpdateProfileRequestDto.fromEntity(UpdateProfileParams entity)
    : fullName = entity.fullName,
      email = entity.email,
      phoneNumber = entity.phoneNumber,
      gender = entity.gender,
      photoPath = entity.photoUrl;
}
