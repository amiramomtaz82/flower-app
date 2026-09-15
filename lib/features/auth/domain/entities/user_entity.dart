import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
  final String? driverStatus;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    this.driverStatus,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    role,
    isActive,
    driverStatus,
  ];
}