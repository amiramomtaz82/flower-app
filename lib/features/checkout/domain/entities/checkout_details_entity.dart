// lib/features/checkout/domain/entities/checkout_details_entity.dart
import 'package:equatable/equatable.dart';

class CheckoutDetailsEntity extends Equatable {
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String? estimatedDeliveryAt;
  final List<PaymentMethodOptionEntity> paymentMethods;
  final bool isGift;
  final String? giftRecipientName;
  final String? giftRecipientPhone;

  const CheckoutDetailsEntity({
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    this.estimatedDeliveryAt,
    required this.paymentMethods,
    required this.isGift,
    this.giftRecipientName,
    this.giftRecipientPhone,
  });

  @override
  List<Object?> get props => [
    subtotal,
    deliveryFee,
    total,
    estimatedDeliveryAt,
    paymentMethods,
    isGift,
    giftRecipientName,
    giftRecipientPhone,
  ];
}

class PaymentMethodOptionEntity extends Equatable {
  final String method; // e.g. "COD", "Card"
  final List<String> gateways;

  const PaymentMethodOptionEntity({
    required this.method,
    this.gateways = const [],
  });

  @override
  List<Object?> get props => [method, gateways];
}