import 'dart:io';

import 'package:dio/dio.dart';
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

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      'FullName': fullName,
      'Email': email,
      'Phone': phoneNumber,
      'PhoneNumber': phoneNumber,
      'Gender': gender,
    };

    if (photoPath != null && photoPath!.isNotEmpty) {
      final file = File(photoPath!);
      if (file.existsSync()) {
        final filename = photoPath!.split(RegExp(r'[/\\]')).last;
        map['Photo'] = await MultipartFile.fromFile(
          file.path,
          filename: filename,
        );
      }
    }

    return FormData.fromMap(map);
  }
}
