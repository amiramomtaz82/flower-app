
import 'package:flower_app/features/check_out/domain/entities/card_payment_session_entity.dart';

import 'gift_recipient_entity.dart';

class PlaceOrderRequestEntity {
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
}


