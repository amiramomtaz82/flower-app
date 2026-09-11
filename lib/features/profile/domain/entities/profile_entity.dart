import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String name;
  final String email;
  final String profileImageUrl;

  const ProfileEntity({
    required this.name,
    required this.email,
    required this.profileImageUrl,
  });

  @override
  List<Object?> get props => [name, email, profileImageUrl];
}
