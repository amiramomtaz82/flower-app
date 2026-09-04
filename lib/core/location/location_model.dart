import 'package:equatable/equatable.dart';

class LocationModel extends Equatable {
  final double? lat;
  final double? lng;
  final String? addressLine;

  final String? state;
  final String? city;
  final String? town;
  final String? municipality;
  final String? suburb;
  final String? neighbourhood;
  final String? cityDistrict;

  const LocationModel({
    this.lat,
    this.lng,
    this.addressLine,
    this.state,
    this.city,
    this.town,
    this.municipality,
    this.suburb,
    this.neighbourhood,
    this.cityDistrict,
  });

  @override
  List<Object?> get props => [lat, lng, addressLine, city, area];
}