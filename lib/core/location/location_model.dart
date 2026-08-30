class LocationModel {
  final double lat;
  final double lng;

  final String? addressLine;

  final String? state;
  final String? city;
  final String? town;
  final String? municipality;
  final String? suburb;
  final String? neighbourhood;
  final String? cityDistrict;

  const LocationModel({
    required this.lat,
    required this.lng,
    this.addressLine,
    this.state,
    this.city,
    this.town,
    this.municipality,
    this.suburb,
    this.neighbourhood,
    this.cityDistrict,
  });
}