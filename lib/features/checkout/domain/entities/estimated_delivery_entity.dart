import 'package:equatable/equatable.dart';

class EstimateDeliveryEntity extends Equatable {
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

  @override
  List<Object?> get props => [
    addressId,
    isServiceable,
    deliveryFee,
    estimatedDeliveryAt,
  ];
}