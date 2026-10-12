import 'package:flower_app/features/profile/domain/entities/profile_entity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'profile_response_model.g.dart';

@JsonSerializable()
class ProfileResponseModel {
  @JsonKey(name: "id")
  final String id;
  @JsonKey(name: "fullName")
  final String fullName;
  @JsonKey(name: "email")
  final String email;
  @JsonKey(name: "phone")
  final String phone;
  @JsonKey(name: "gender")
  final String gender;
  @JsonKey(name: "photoUrl")
  final String photoUrl;

  ProfileResponseModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.photoUrl,
  });

  ProfileResponseModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? gender,
    String? photoUrl,
  }) => ProfileResponseModel(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    gender: gender ?? this.gender,
    photoUrl: photoUrl ?? this.photoUrl,
  );

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileResponseModelToJson(this);

  ProfileEntity toEntity() => ProfileEntity(
    name: fullName,
    email: email,
    phoneNumber: phone,
    gender: gender,
    profileImageUrl: photoUrl,
  );
}
