import '../../domain/entities/address_entity.dart';

class AddressDto {
  AddressDto({
    this.id,
    this.recipientName,
    this.recipientPhone,
    this.addressLine,
    this.cityId,
    this.areaId,
    this.lat,
    this.lng,
    this.label,
    this.isDefault,
    this.storeId,
    this.createdAt,});

  AddressDto.fromJson(dynamic json) {
    id = json['id'];
    recipientName = json['recipientName'];
    recipientPhone = json['recipientPhone'];
    addressLine = json['addressLine'];
    cityId = json['cityId'];
    areaId = json['areaId'];
    lat = json['lat'];
    lng = json['lng'];
    label = json['label'];
    isDefault = json['isDefault'];
    storeId = json['storeId'];
    createdAt = json['createdAt'];
  }
  String? id;
  String? recipientName;
  String? recipientPhone;
  String? addressLine;
  String? cityId;
  String? areaId;
  num? lat;
  num? lng;
  String? label;
  bool? isDefault;
  String? storeId;
  String? createdAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['recipientName'] = recipientName;
    map['recipientPhone'] = recipientPhone;
    map['addressLine'] = addressLine;
    map['cityId'] = cityId;
    map['areaId'] = areaId;
    map['lat'] = lat;
    map['lng'] = lng;
    map['label'] = label;
    map['isDefault'] = isDefault;
    map['storeId'] = storeId;
    map['createdAt'] = createdAt;
    return map;
  }
  AddressEntity toEntity() {
    return AddressEntity(
      id: id,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      addressLine: addressLine,
      cityId: cityId,
      areaId: areaId,
      lat: lat?.toDouble(),
      lng: lng?.toDouble(),
      label: label,
      isDefault: isDefault,
      storeId: storeId,
      createdAt: createdAt,
    );
  }
}