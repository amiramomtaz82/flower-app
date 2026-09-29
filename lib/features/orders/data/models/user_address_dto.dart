import '../../domain/entities/user_address_entity.dart';

class UserAddress {
  UserAddress({
    this.lat,
    this.lng,
    this.addressLine,
  });
  UserAddress.fromJson(dynamic json) {
    lat = json['lat'];
    lng = json['lng'];
    addressLine = json['addressLine'];
  }
  num? lat;
  num? lng;
  String? addressLine;
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['lat'] = lat;
    map['lng'] = lng;
    map['addressLine'] = addressLine;
    return map;
  }
  UserAddressEntity toEntity() => UserAddressEntity(
    lat: (lat ?? 30.0444).toDouble(),
    lng: (lng ?? 31.2357).toDouble(),
    addressLine: addressLine ?? '',
  );
}