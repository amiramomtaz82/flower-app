import '../../domain/entities/cod_payment_entity.dart';

class CodPaymentResponse {
  final bool isSuccess;
  final String message;
  final String statusCode;
  final CodPaymentDto? data;

  CodPaymentResponse({
    required this.isSuccess,
    required this.message,
    required this.statusCode,
    this.data,
  });

  factory CodPaymentResponse.fromJson(Map<String, dynamic> json) {
    return CodPaymentResponse(
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      statusCode: json['statusCode']?.toString() ?? '',
      data: json['data'] != null ? CodPaymentDto.fromJson(json['data']) : null,
    );
  }
}

class CodPaymentDto {
  final String orderId;
  final String status;
  final String paymentMethod;

  CodPaymentDto({
    required this.orderId,
    required this.status,
    required this.paymentMethod,
  });

  factory CodPaymentDto.fromJson(Map<String, dynamic> json) {
    return CodPaymentDto(
      orderId: json['orderId'] ?? '',
      status: json['status'] ?? '',
      paymentMethod: json['paymentMethod'] ?? 'COD',
    );
  }

  /// Converts DTO to Domain Entity
  CodPaymentEntity toEntity() {
    return CodPaymentEntity(
      orderId: orderId,
      status: status,
      paymentMethod: paymentMethod,
    );
  }
}