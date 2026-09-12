import 'package:equatable/equatable.dart';

import 'gift_recipient_entity.dart';

class PlaceOrderRequestEntity extends Equatable {
  final String cartId;
  final String addressId;
  final bool isGift;
  final GiftRecipientEntity? giftRecipient;
  final String paymentMethod;
  final String? paymentGateway;

  const PlaceOrderRequestEntity({
    required this.cartId,
    required this.addressId,
    this.isGift = false,
    this.giftRecipient,
    required this.paymentMethod,
    this.paymentGateway,
  });

  @override
  List<Object?> get props => [
    cartId,
    addressId,
    isGift,
    giftRecipient,
    paymentMethod,
    paymentGateway,
  ];
}