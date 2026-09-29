import 'order_traching_dto.dart';

class OrderTackingResponse {
  OrderTackingResponse({
    this.data,
    this.isSuccess,
    this.message,
    this.messageLocalized,
    this.statusCode,
  });
  OrderTackingResponse.fromJson(dynamic json) {
    data = json['data'] != null ? OrderTrackingDto.fromJson(json['data']) : null;
    isSuccess = json['isSuccess'];
    message = json['message'];
    messageLocalized = json['messageLocalized'];
    statusCode = json['statusCode'];
  }
  OrderTrackingDto? data;
  bool? isSuccess;
  String? message;
  String? messageLocalized;
  String? statusCode;
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data?.toJson();
    }
    map['isSuccess'] = isSuccess;
    map['message'] = message;
    map['messageLocalized'] = messageLocalized;
    map['statusCode'] = statusCode;
    return map;
  }
}