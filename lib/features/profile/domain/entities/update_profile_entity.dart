import 'package:equatable/equatable.dart';

class UpdateProfileParams extends Equatable {
  final String fullName;
  final String email;
  final String photoUrl;
  final String gender;
  final String phoneNumber;

  const UpdateProfileParams({
    required this.fullName,
    required this.email,
    required this.photoUrl,
    required this.gender,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [fullName, email, photoUrl, gender, phoneNumber];
}
