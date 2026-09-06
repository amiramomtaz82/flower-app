/// recipientName : "Layla Hassan"
/// phone : "01111111101"
/// addressLine : "123 Tahrir Square, Downtown"
/// cityId : "00000000-0000-0000-0000-000000000001"
/// areaId : "00000000-0000-0000-0000-000000000002"
/// latitude : 30.0444
/// longitude : 31.2357
/// label : "Home"

class CreateAddressRequest {
  CreateAddressRequest({
      this.recipientName, 
      this.phone, 
      this.addressLine, 
      this.cityId, 
      this.areaId, 
      this.latitude, 
      this.longitude, 
      this.label,});

  CreateAddressRequest.fromJson(dynamic json) {
    recipientName = json['recipientName'];
    phone = json['phone'];
    addressLine = json['addressLine'];
    cityId = json['cityId'];
    areaId = json['areaId'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    label = json['label'];
  }
  String? recipientName;
  String? phone;
  String? addressLine;
  String? cityId;
  String? areaId;
  num? latitude;
  num? longitude;
  String? label;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['recipientName'] = recipientName;
    map['phone'] = phone;
    map['addressLine'] = addressLine;
    map['cityId'] = cityId;
    map['areaId'] = areaId;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['label'] = label;
    return map;
  }

}