import 'package:equatable/equatable.dart';

class AddAddressEntity extends Equatable {
  final String recipientName;
  final String recipientPhone;
  final String addressLine;
  final String city;
  final String area;
  final double lat;
  final double lng;
  final String label;

  const AddAddressEntity({
    required this.recipientName,
    required this.recipientPhone,
    required this.addressLine,
    required this.city,
    required this.area,
    required this.lat,
    required this.lng,
    required this.label,
  });

  @override
  List<Object?> get props => [
    recipientName,
    recipientPhone,
    addressLine,
    city,
    area,
    lat,
    lng,
    label,
  ];
}