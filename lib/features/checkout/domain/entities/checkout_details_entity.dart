// lib/features/checkout/domain/entities/checkout_details_entity.dart
import 'package:equatable/equatable.dart';

class CheckoutDetailsEntity extends Equatable {
  final String cartId;
  final String? addressId;
  final bool isServiceable;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String? estimatedDeliveryAt;
  final List<PaymentMethodOptionEntity> paymentMethods;
  final bool isGift;

  const CheckoutDetailsEntity({
    required this.cartId,
    this.addressId,
    required this.isServiceable,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    this.estimatedDeliveryAt,
    required this.paymentMethods,
    required this.isGift,
  });

  @override
  List<Object?> get props => [
    cartId,
    addressId,
    isServiceable,
    subtotal,
    deliveryFee,
    total,
    estimatedDeliveryAt,
    paymentMethods,
    isGift,
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