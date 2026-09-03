import 'addressdto.dart';

/// data : [{"id":"3fa85f64-5717-4562-b3fc-2c963f66afa6","recipientName":"Mona Ahmed","recipientPhone":"01012345678","addressLine":"12 Nile Street, Building 4, Apt 6","city":"Giza","area":"Dokki","lat":30.0131,"lng":31.2089,"label":"Home","isDefault":true,"storeId":"3fa85f64-5717-4562-b3fc-2c963f66afa6","isServiceable":true,"createdAt":"2026-08-26T09:46:53.027Z"}]
/// isSuccess : true
/// message : "string"
/// messageLocalized : "string"
/// statusCode : "Success"

class SavedAddressesResponse {
  SavedAddressesResponse({
      this.data, 
      this.isSuccess, 
      this.message, 
      this.messageLocalized, 
      this.statusCode,});

  SavedAddressesResponse.fromJson(dynamic json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(AddressDto.fromJson(v));
      });
    }
    isSuccess = json['isSuccess'];
    message = json['message'];
    messageLocalized = json['messageLocalized'];
    statusCode = json['statusCode'];
  }
  List<AddressDto>? data;
  bool? isSuccess;
  String? message;
  String? messageLocalized;
  String? statusCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    map['isSuccess'] = isSuccess;
    map['message'] = message;
    map['messageLocalized'] = messageLocalized;
    map['statusCode'] = statusCode;
    return map;
  }

}

/// id : "3fa85f64-5717-4562-b3fc-2c963f66afa6"
/// recipientName : "Mona Ahmed"
/// recipientPhone : "01012345678"
/// addressLine : "12 Nile Street, Building 4, Apt 6"
/// city : "Giza"
/// area : "Dokki"
/// lat : 30.0131
/// lng : 31.2089
/// label : "Home"
/// isDefault : true
/// storeId : "3fa85f64-5717-4562-b3fc-2c963f66afa6"
/// isServiceable : true
/// createdAt : "2026-08-26T09:46:53.027Z"

