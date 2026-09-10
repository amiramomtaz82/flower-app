import '../../domain/entities/address_entity.dart';

class AddressDto {
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
  bool? isServiceable;
  String? createdAt;

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
    this.isServiceable,
    this.createdAt,
  });

  AddressDto.fromJson(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) return;

    id = (json['id'] ?? json['_id'])?.toString();
    recipientName = (json['recipientName'] ?? json['name'])?.toString();
    recipientPhone = (json['recipientPhone'] ?? json['phone'])?.toString();
    addressLine = (json['addressLine'] ?? json['address'])?.toString();

    // Extract City ID safely
    if (json['cityId'] != null) {
      cityId = json['cityId'].toString();
    } else if (json['city'] is Map<String, dynamic>) {
      cityId = (json['city']['id'] ?? json['city']['_id'])?.toString();
    } else if (json['city'] is String) {
      cityId = json['city'];
    }

    // Extract Area ID safely
    if (json['areaId'] != null) {
      areaId = json['areaId'].toString();
    } else if (json['area'] is Map<String, dynamic>) {
      areaId = (json['area']['id'] ?? json['area']['_id'])?.toString();
    } else if (json['area'] is String) {
      areaId = json['area'];
    }

    lat = (json['latitude'] ?? json['lat']) as num?;
    lng = (json['longitude'] ?? json['lng']) as num?;
    label = json['label']?.toString();
    isDefault = json['isDefault'] as bool?;
    storeId = json['storeId']?.toString();
    isServiceable = json['isServiceable'] as bool?;
    createdAt = json['createdAt']?.toString();
  }
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['recipientName'] = recipientName;
    map['recipientPhone'] = recipientPhone;
    map['addressLine'] = addressLine;
    map['city'] = cityId;
    map['area'] = areaId;
    map['lat'] = lat;
    map['lng'] = lng;
    map['label'] = label;
    map['isDefault'] = isDefault;
    map['storeId'] = storeId;
    map['isServiceable'] = isServiceable;
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
      isServiceable: isServiceable,
      createdAt: createdAt,
    );
  }
}