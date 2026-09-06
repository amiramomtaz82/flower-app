

import '../../domain/entities/checkout_details_entity.dart';
import '../../domain/entities/place_order_request_entity.dart';

class CheckoutDetailsResponse {
  final CheckoutDetailsDto? data;
  final bool isSuccess;
  final String message;
  final String? messageLocalized;
  final String statusCode;

  CheckoutDetailsResponse({
    this.data,
    required this.isSuccess,
    required this.message,
    this.messageLocalized,
    required this.statusCode,
  });

  factory CheckoutDetailsResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutDetailsResponse(
      data: json['data'] != null ? CheckoutDetailsDto.fromJson(json['data']) : null,
      isSuccess: json['isSuccess'] ?? false,
      message: json['message'] ?? '',
      messageLocalized: json['messageLocalized'],
      statusCode: json['statusCode'] ?? '',
    );
  }
}

class CheckoutDetailsDto {
  final String cartId;
  final String? addressId;
  final bool isServiceable;
  final double subtotal;
  final double? deliveryFee;
  final double total;
  final String? estimatedDeliveryAt;
  final List<PaymentMethodOption> paymentMethods;
  final bool isGift;
  final String? giftRecipientName;
  final String? giftRecipientPhone;

  CheckoutDetailsDto({
    required this.cartId,
    this.addressId,
    required this.isServiceable,
    required this.subtotal,
    this.deliveryFee,
    required this.total,
    this.estimatedDeliveryAt,
    required this.paymentMethods,
    required this.isGift,
    this.giftRecipientName,
    this.giftRecipientPhone,
  });

  factory CheckoutDetailsDto.fromJson(Map<String, dynamic> json) {
    return CheckoutDetailsDto(
      cartId: json['cartId'] ?? '',
      addressId: json['addressId'],
      isServiceable: json['isServiceable'] ?? false,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      estimatedDeliveryAt: json['estimatedDeliveryAt'],
      paymentMethods: (json['paymentMethods'] as List<dynamic>?)
          ?.map((item) => PaymentMethodOption.fromJson(item))
          .toList() ??
          [],
      isGift: json['isGift'] ?? false,
      giftRecipientName: json['giftRecipientName'],
      giftRecipientPhone: json['giftRecipientPhone'],
    );
  }

  CheckoutDetailsEntity toEntity() {
    return CheckoutDetailsEntity(
      cartId: cartId,
      addressId: addressId,
      isServiceable: isServiceable,
      subtotal: subtotal,
      deliveryFee: deliveryFee ?? 0.0,
      total: total,
      estimatedDeliveryAt: estimatedDeliveryAt,
      paymentMethods: paymentMethods.map((p) => p.method).toList(),
      availableGateways: paymentMethods
          .firstWhere((p) => p.method == 'Card', orElse: () => PaymentMethodOption(method: 'Card', gateways: []))
          .gateways,
      isGift: isGift,
    );
  }
}

class PaymentMethodOption {
  final String method; // 'COD' or 'Card'
  final List<String> gateways;

  PaymentMethodOption({
    required this.method,
    this.gateways = const [],
  });

  factory PaymentMethodOption.fromJson(Map<String, dynamic> json) {
    return PaymentMethodOption(
      method: json['method'] ?? '',
      gateways: (json['gateways'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}