
import '../../domain/entities/place_order_request_entity.dart';
import '../models/place_order_request.dart';

extension PlaceOrderEntityMapper on PlaceOrderRequestEntity {
  PlaceOrderRequest toDto() {
    return PlaceOrderRequest(
      cartId: cartId,
      addressId: addressId,
      isGift: isGift,
      giftRecipientName: isGift ? giftRecipient?.name : null,
      giftRecipientPhone: isGift ? giftRecipient?.phone : null,
      paymentMethod: paymentMethod,
      paymentGateway: paymentGateway,
    );
  }
}