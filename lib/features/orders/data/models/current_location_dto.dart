import '../../domain/entities/current_location_entity.dart';

class CurrentLocation {
  CurrentLocation({
    this.lat,
    this.lng,
    this.recordedAt,
    this.isStale,
  });
  CurrentLocation.fromJson(dynamic json) {
    lat = json['lat'];
    lng = json['lng'];
    recordedAt = json['recordedAt'];
    isStale = json['isStale'];
  }
  num? lat;
  num? lng;
  String? recordedAt;
  bool? isStale;
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['lat'] = lat;
    map['lng'] = lng;
    map['recordedAt'] = recordedAt;
    map['isStale'] = isStale;
    return map;
  }
  CurrentLocationEntity toEntity() => CurrentLocationEntity(
    lat: (lat ?? 0).toDouble(),
    lng: (lng ?? 0).toDouble(),
    recordedAt: DateTime.tryParse(recordedAt ?? '') ?? DateTime.now(),
    isStale: isStale ?? false,
  );
}