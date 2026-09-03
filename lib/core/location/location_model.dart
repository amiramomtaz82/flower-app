import 'package:equatable/equatable.dart';

class LocationModel extends Equatable {
  final double? lat;
  final double? lng;
  final String? addressLine;
  final String? city;
  final String? area;

  const LocationModel({
    this.lat,
    this.lng,
    this.addressLine,
    this.city,
    this.area,
  });

  @override
  List<Object?> get props => [lat, lng, addressLine, city, area];
}