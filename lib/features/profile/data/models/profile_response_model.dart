import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'profile_response_model.g.dart';

@JsonSerializable()
class ProfileResponseModel {
  final String name;
  final String email;
  final String profileImageUrl;
  final String gender;
  final String phoneNumber;
  ProfileResponseModel({
    required this.name,
    required this.email,
    required this.profileImageUrl,
    required this.gender,
    required this.phoneNumber,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileResponseModelToJson(this);

  ProfileEntity toEntity() =>
      ProfileEntity(name: name, email: email, profileImageUrl: profileImageUrl);
}
