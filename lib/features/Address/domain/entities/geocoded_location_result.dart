import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/location/location_model.dart';
import 'area_entity.dart';
import 'city_entity.dart';

class GeocodedLocationResult extends Equatable {
  final LatLng location;
  final LocationModel details;
  final AreaEntity? matchedArea;
  final CityEntity? matchedCity;

  const GeocodedLocationResult({
    required this.location,
    required this.details,
    this.matchedArea,
    this.matchedCity,
  });

  @override
  List<Object?> get props => [
    location,
    details,
    matchedArea,
    matchedCity,
  ];
}