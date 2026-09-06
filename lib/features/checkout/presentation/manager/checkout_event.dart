// lib/features/checkout/presentation/cubit/checkout_events.dart
import 'package:equatable/equatable.dart';

enum PaymentMethodType { cash, card }

sealed class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

class GetCheckoutDetailsEvent extends CheckoutEvent {
  final String cartId;
  final String? defaultAddressId;

  const GetCheckoutDetailsEvent({required this.cartId, this.defaultAddressId});

  @override
  List<Object?> get props => [cartId, defaultAddressId];
}

class EstimateDeliveryEvent extends CheckoutEvent {
  final String addressId;
  final String cartId;

  const EstimateDeliveryEvent({required this.addressId, required this.cartId});

  @override
  List<Object?> get props => [addressId, cartId];
}

class SelectPaymentMethodEvent extends CheckoutEvent {
  final PaymentMethodType paymentMethod;

  const SelectPaymentMethodEvent(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

class ToggleGiftEvent extends CheckoutEvent {
  final bool isGift;

  const ToggleGiftEvent(this.isGift);

  @override
  List<Object?> get props => [isGift];
}

class UpdateGiftDetailsEvent extends CheckoutEvent {
  final String? name;
  final String? phone;

  const UpdateGiftDetailsEvent({this.name, this.phone});

  @override
  List<Object?> get props => [name, phone];
}

class PlaceOrderEvent extends CheckoutEvent {
  final String cartId;

  const PlaceOrderEvent(this.cartId);

  @override
  List<Object?> get props => [cartId];
}

class ResetPlaceOrderStateEvent extends CheckoutEvent {
  const ResetPlaceOrderStateEvent();
}