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

  String get firstName {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    final parts = trimmed.split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : '';
  }

  String get lastName {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    final parts = trimmed.split(RegExp(r'\s+'));
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  @override
  List<Object?> get props => [name, email, profileImageUrl, gender, phoneNumber];
}
