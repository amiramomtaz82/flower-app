import 'package:equatable/equatable.dart';

class UserAddressEntity extends Equatable {
  final double lat;
  final double lng;
  final String addressLine;
  const UserAddressEntity({
    required this.lat,
    required this.lng,
    required this.addressLine,
  });
  @override
  List<Object?> get props => [lat, lng, addressLine];
}
