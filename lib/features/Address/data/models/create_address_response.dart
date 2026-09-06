import 'addressdto.dart';

/// success : true
/// message : "Address created successfully."
/// data : {"id":"01a04e0d-0b92-7bf1-9350-42eb9581c8d2","recipientName":"Mona Ahmed","recipientPhone":"01012345678","addressLine":"15 Abbas El Akkad Street, Building 4","cityId":"c1000000-0000-0000-0000-000000000039","areaId":"a1000000-0000-0000-0000-000000000001","lat":30.0511,"lng":31.3656,"label":"Home","isDefault":true,"storeId":"de89bb21-d732-4e6f-a657-ebd709e1ce4b","createdAt":"2026-08-29T15:04:32.9157153Z"}
/// error : null

class CreateAddressResponse {
  CreateAddressResponse({
      this.success, 
      this.message, 
      this.data, 
      this.error,});

  CreateAddressResponse.fromJson(dynamic json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? AddressDto.fromJson(json['data']) : null;
    error = json['error'];
  }
  bool? success;
  String? message;
  AddressDto? data;
  dynamic error;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    map['error'] = error;
    return map;
  }

}

/// id : "01a04e0d-0b92-7bf1-9350-42eb9581c8d2"
/// recipientName : "Mona Ahmed"
/// recipientPhone : "01012345678"
/// addressLine : "15 Abbas El Akkad Street, Building 4"
/// cityId : "c1000000-0000-0000-0000-000000000039"
/// areaId : "a1000000-0000-0000-0000-000000000001"
/// lat : 30.0511
/// lng : 31.3656
/// label : "Home"
/// isDefault : true
/// storeId : "de89bb21-d732-4e6f-a657-ebd709e1ce4b"
/// createdAt : "2026-08-29T15:04:32.9157153Z"

