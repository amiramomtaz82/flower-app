import '../../domain/entities/profile_entity.dart';

import 'package:json_annotation/json_annotation.dart';


part 'profile_response_model.g.dart';
@JsonSerializable()
class ProfileResponseModel {
  final String? id;

  @JsonKey(name: 'fullName')
  final String name;

  final String email;

  @JsonKey(name: 'photoUrl')
  final String profileImageUrl;

  final String gender;

  @JsonKey(name: 'phone')
  final String phoneNumber;

  ProfileResponseModel({
    this.id,
    required this.name,
    required this.email,
    required this.profileImageUrl,
    required this.gender,
    required this.phoneNumber,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileResponseModelToJson(this);

  ProfileEntity toEntity() => ProfileEntity(
    name: name,
    email: email,
    profileImageUrl: profileImageUrl,
    gender: gender,
    phoneNumber: phoneNumber,
  );
}