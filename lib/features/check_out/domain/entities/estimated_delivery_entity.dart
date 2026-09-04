class EstimateDeliveryEntity {
  final String addressId;
  final bool isServiceable;
  final double deliveryFee;
  final String? estimatedDeliveryAt;

  const EstimateDeliveryEntity({
    required this.addressId,
    required this.isServiceable,
    required this.deliveryFee,
    this.estimatedDeliveryAt,
  });
}