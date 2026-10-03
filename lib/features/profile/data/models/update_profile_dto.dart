import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flower_app/features/profile/domain/entities/update_profile_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_profile_dto.g.dart';

@JsonSerializable()
class UpdateProfileRequestDto {
  @JsonKey(name: "fullName")
  final String fullName;
  @JsonKey(name: "email")
  final String email;
  @JsonKey(name: "phoneNumber")
  final String phoneNumber;
  @JsonKey(name: "gender")
  final String gender;
  @JsonKey(name: "photoUrl", toJson: _fileToJson, fromJson: _fileFromJson)
  final MultipartFile? photoUrl;

  UpdateProfileRequestDto({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    this.photoUrl,
  });

  factory UpdateProfileRequestDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestDtoToJson(this);

  static dynamic _fileToJson(MultipartFile? file) => file;
  static MultipartFile? _fileFromJson(dynamic json) => null;

  // Convert UpdateProfileEntity to UpdateProfileDto
  UpdateProfileRequestDto.fromEntity(UpdateProfileParams entity)
    : fullName = entity.fullName,
      email = entity.email,
      phoneNumber = entity.phoneNumber,
      gender = entity.gender,
      photoUrl =
          (entity.photoUrl.isNotEmpty && File(entity.photoUrl).existsSync())
          ? MultipartFile.fromFileSync(
              entity.photoUrl,
              filename: entity.photoUrl.split(RegExp(r'[/\\]')).last,
            )
          : null;
}
