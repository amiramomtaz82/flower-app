

import 'package:flower_app/features/checkout/data/models/place_order_request.dart';

import '../../domain/entities/place_order_request_entity.dart';

extension PlaceOrderEntityMapper on PlaceOrderRequestEntity {
  PlaceOrderRequest toDto() {
    return PlaceOrderRequest(
      cartId: cartId,
      addressId: addressId,
      isGift: isGift,
      giftRecipient: isGift && giftRecipient != null
          ? GiftRecipientRequest(
        recipientName: giftRecipient!.name,
        recipientPhone: giftRecipient!.phone,
      )
          : null,
      paymentMethod: paymentMethod,
      paymentGateway: paymentGateway,
    );
  }
}