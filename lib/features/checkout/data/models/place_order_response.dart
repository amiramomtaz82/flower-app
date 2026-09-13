
import '../../domain/entities/card_payment_session_entity.dart';
import '../../domain/entities/place_order_request_entity.dart';

class PlaceOrderResponse {
  final CardPaymentSessionDto? data; // null for COD orders
  final bool isSuccess;
  final String message;
  final String? messageLocalized;
  final String statusCode;

  PlaceOrderResponse({
    this.data,
    required this.isSuccess,
    required this.message,
    this.messageLocalized,
    required this.statusCode,
  });

  factory PlaceOrderResponse.fromJson(Map<String, dynamic> json) {
    return PlaceOrderResponse(
      data: json['data'] != null ? CardPaymentSessionDto.fromJson(json['data']) : null,
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      messageLocalized: json['messageLocalized'],
      statusCode: json['statusCode'] ?? '',
    );
  }
}

class CardPaymentSessionDto {
  final String orderId;
  final String status;
  final String gateway;
  final String sessionId;
  final String sessionUrl;
  final String successUrl;
  final String cancelUrl;
  final String expiresAt;
  final double amount;
  final String currency;
  final String estimatedDeliveryAt;

  CardPaymentSessionDto({
    required this.orderId,
    required this.status,
    required this.gateway,
    required this.sessionId,
    required this.sessionUrl,
    required this.successUrl,
    required this.cancelUrl,
    required this.expiresAt,
    required this.amount,
    required this.currency,
    required this.estimatedDeliveryAt,
  });

  factory CardPaymentSessionDto.fromJson(Map<String, dynamic> json) {
    return CardPaymentSessionDto(
      orderId: json['orderId'] ?? '',
      status: json['status'] ?? '',
      gateway: json['gateway'] ?? '',
      sessionId: json['sessionId'] ?? '',
      sessionUrl: json['sessionUrl'] ?? '',
      successUrl: json['successUrl'] ?? '',
      cancelUrl: json['cancelUrl'] ?? '',
      expiresAt: json['expiresAt'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'EGP',
      estimatedDeliveryAt: json['estimatedDeliveryAt'] ?? '',
    );
  }

  CardPaymentSessionEntity toEntity() {
    return CardPaymentSessionEntity(
      orderId: orderId,
      status: status,
      gateway: gateway,
      sessionId: sessionId,
      sessionUrl: sessionUrl,
      successUrl: successUrl,
      cancelUrl: cancelUrl,
      expiresAt: expiresAt,
      amount: amount,
      currency: currency,
      estimatedDeliveryAt: estimatedDeliveryAt,
    );
  }
}