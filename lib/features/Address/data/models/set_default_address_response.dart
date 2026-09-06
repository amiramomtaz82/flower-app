


import 'addressdto.dart';

class SetDefaultAddressResponse {
  final AddressDto? data;
  final bool? isSuccess;
  final String? message;
  final String? messageLocalized;
  final String? statusCode;

  SetDefaultAddressResponse({
    this.data,
    this.isSuccess,
    this.message,
    this.messageLocalized,
    this.statusCode,
  });

  factory SetDefaultAddressResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return SetDefaultAddressResponse(
      data: json['data'] != null
          ? AddressDto.fromJson(json['data'])
          : null,
      isSuccess: json['isSuccess'],
      message: json['message'],
      messageLocalized: json['messageLocalized'],
      statusCode: json['statusCode'],
    );
  }
}