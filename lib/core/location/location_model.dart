class LocationModel {
  final double lat;
  final double lng;

  final String? addressLine;
  final String? city;
  final String? area;

  const LocationModel({
    required this.lat,
    required this.lng,
    this.addressLine,
    this.city,
    this.area,
  });
}