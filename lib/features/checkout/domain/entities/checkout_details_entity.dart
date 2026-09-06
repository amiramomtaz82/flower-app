class CheckoutDetailsEntity {
  final String cartId;
  final String? addressId;
  final bool isServiceable;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String? estimatedDeliveryAt;
  final List<String> paymentMethods;
  final List<String> availableGateways;
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
    required this.availableGateways,
    required this.isGift,
  });
}