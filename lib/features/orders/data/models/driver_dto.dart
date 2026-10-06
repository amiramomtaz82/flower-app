import '../../domain/entities/driver_entity.dart';

class DriverDto {
  DriverDto({
    this.driverId,
    this.name,
    this.photoUrl,
    this.phone,
  });
  DriverDto.fromJson(dynamic json) {
    driverId = json['driverId'];
    name = json['name'];
    photoUrl = json['photoUrl'];
    phone = json['phone'];
  }
  String? driverId;
  String? name;
  String? photoUrl;
  String? phone;
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['driverId'] = driverId;
    map['name'] = name;
    map['photoUrl'] = photoUrl;
    map['phone'] = phone;
    return map;
  }
  DriverEntity toEntity() => DriverEntity(
    driverId: driverId ?? '',
    name: name ?? 'Delivery Hero',
    phone: phone ?? '',
    photoUrl: photoUrl,
  );
}