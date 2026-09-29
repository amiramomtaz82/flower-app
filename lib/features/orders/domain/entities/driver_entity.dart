import 'package:equatable/equatable.dart';

class DriverEntity extends Equatable {
  final String driverId;
  final String name;
  final String phone;
  final String? photoUrl;
  const DriverEntity({
    required this.driverId,
    required this.name,
    required this.phone,
    this.photoUrl,
  });
  @override
  List<Object?> get props => [driverId, name, phone, photoUrl];
}
