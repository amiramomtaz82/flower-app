
import '../../domain/entities/card_payment_session_entity.dart';

class PlaceOrderResponse {
  final CardPaymentSessionDto? data; // null for COD orders
  final bool isSuccess;
  final String message;
  final String? messageLocalized;
  final String statusCode;
  final String? orderId;

  PlaceOrderResponse({
    this.data,
    required this.isSuccess,
    required this.message,
    this.messageLocalized,
    required this.statusCode,
    this.orderId
  });

  factory PlaceOrderResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] is Map ? json['data'] as Map<String, dynamic> : null;
    final orderMap = json['order'] is Map ? json['order'] as Map<String, dynamic> : null;

    final resolvedOrderId = json['orderId']?.toString() ??
        json['id']?.toString() ??
        json['_id']?.toString() ??
        dataMap?['orderId']?.toString() ??
        dataMap?['id']?.toString() ??
        dataMap?['_id']?.toString() ??
        orderMap?['orderId']?.toString() ??
        orderMap?['id']?.toString() ??
        orderMap?['_id']?.toString() ??
        (json['data'] is String ? json['data'] as String : null);

    final uuidRegex = RegExp(r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}');
    final messageUuid = json['message'] != null
        ? uuidRegex.firstMatch(json['message'].toString())?.group(0)
        : null;

    final finalOrderId = resolvedOrderId ?? messageUuid;

    final isCardSession = dataMap != null &&
        (dataMap.containsKey('sessionUrl') || dataMap.containsKey('sessionId'));

    return PlaceOrderResponse(
      orderId: finalOrderId,
      data: isCardSession ? CardPaymentSessionDto.fromJson(dataMap) : null,
      isSuccess: json['isSuccess'] == true || json['success'] == true,
      message: json['message']?.toString() ?? '',
      messageLocalized: json['messageLocalized']?.toString(),
      statusCode: json['statusCode']?.toString() ?? '',
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