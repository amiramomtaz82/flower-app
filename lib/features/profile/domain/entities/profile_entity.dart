import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String name;
  final String email;
  final String profileImageUrl;
  final String? gender;
  final String? phoneNumber;

  const ProfileEntity({
    required this.name,
    required this.email,
    required this.profileImageUrl,
    this.gender,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [name, email, profileImageUrl, gender, phoneNumber];
}
