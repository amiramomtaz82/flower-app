import '../../domain/entities/checkout_details_entity.dart';
import 'checkout_details_dto.dart';

class CheckoutDetailsResponse {
  CheckoutDetailsResponse({
    this.success,
    this.message,
    this.data,
    this.error,
  });

  CheckoutDetailsResponse.fromJson(dynamic json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? CheckoutDetailsDto.fromJson(json['data']) : null;
    error = json['error'];
  }

  bool? success;
  String? message;
  CheckoutDetailsDto? data;
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



