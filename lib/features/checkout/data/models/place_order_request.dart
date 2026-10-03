class PlaceOrderRequest {
  final String cartId;
  final String addressId;
  final bool isGift;
  final String? giftRecipientName;
  final String? giftRecipientPhone;
  final String paymentMethod;
  final String? paymentGateway;
  final String? notes;

  PlaceOrderRequest({
    required this.cartId,
    required this.addressId,
    this.isGift = false,
    this.giftRecipientName,
    this.giftRecipientPhone,
    required this.paymentMethod,
    this.paymentGateway,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'cartId': cartId,
      'addressId': addressId,
      'isGift': isGift,
      if (isGift && giftRecipientName != null) 'giftRecipientName': giftRecipientName,
      if (isGift && giftRecipientPhone != null) 'giftRecipientPhone': giftRecipientPhone,
      'paymentMethod': paymentMethod,
      if (paymentGateway != null) 'paymentGateway': paymentGateway,
      if (notes != null) 'notes': notes,
    };
  }
}