import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';


part 'user_dto.g.dart';
@JsonSerializable()
class UserDto {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
  final String? driverStatus;

  const UserDto({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    this.driverStatus,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    fullName: fullName,
    role: role,
    isActive: isActive,
    driverStatus: driverStatus,
  );
}