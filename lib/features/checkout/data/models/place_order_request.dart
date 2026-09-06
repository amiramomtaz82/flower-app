

class PlaceOrderRequest {
  final String cartId;
  final String addressId;
  final bool isGift;
  final GiftRecipientRequest? giftRecipient;
  final String paymentMethod; // 'COD' or 'Card'
  final String? paymentGateway; // 'Stripe' or 'Paymob'

  PlaceOrderRequest({
    required this.cartId,
    required this.addressId,
    this.isGift = false,
    this.giftRecipient,
    required this.paymentMethod,
    this.paymentGateway,
  });

  Map<String, dynamic> toJson() {
    return {
      'cartId': cartId,
      'addressId': addressId,
      'isGift': isGift,
      if (isGift && giftRecipient != null)
        'giftRecipient': giftRecipient!.toJson(),
      'paymentMethod': paymentMethod,
      if (paymentGateway != null)
        'paymentGateway': paymentGateway,
    };
  }
}

class GiftRecipientRequest {
  final String recipientName;
  final String recipientPhone;

  GiftRecipientRequest({
    required this.recipientName,
    required this.recipientPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
    };
  }
}