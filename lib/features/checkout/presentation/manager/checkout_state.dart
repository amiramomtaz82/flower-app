// lib/features/checkout/presentation/cubit/checkout_state.dart
import 'package:equatable/equatable.dart';

import '../../../../../config/resource/rsource.dart';
import '../../../Address/domain/entities/address_entity.dart';
import '../../domain/entities/checkout_details_entity.dart';
import '../../domain/entities/estimated_delivery_entity.dart';
import '../../domain/entities/oder_placment_entity.dart';
import 'checkout_event.dart';

class CheckoutState extends Equatable {
  final Resource<CheckoutDetailsEntity> checkoutDetailsResource;
  final Resource<EstimateDeliveryEntity> estimateDeliveryResource;
  final Resource<OrderPlacementEntity> placeOrderResource;
  final List<AddressEntity> addresses;
  final String? selectedAddressId;
  final PaymentMethodType paymentMethod;
  final bool isGift;
  final String? recipientName;
  final String? recipientPhone;

  const CheckoutState({
    required this.checkoutDetailsResource,
    required this.estimateDeliveryResource,
    required this.placeOrderResource,
    required this.addresses,
    this.selectedAddressId,
    this.paymentMethod = PaymentMethodType.cash,
    this.isGift = false,
    this.recipientName,
    this.recipientPhone,
  });

  factory CheckoutState.initial() => CheckoutState(
    checkoutDetailsResource: Resource.initial(),
    estimateDeliveryResource: Resource.initial(),
    placeOrderResource: Resource.initial(),
    selectedAddressId: null,
    paymentMethod: PaymentMethodType.cash,
    isGift: false,
    recipientName: null,
    recipientPhone: null,
    addresses: const [],
  );

  CheckoutState copyWith({
    Resource<CheckoutDetailsEntity>? checkoutDetailsResource,
    Resource<EstimateDeliveryEntity>? estimateDeliveryResource,
    Resource<OrderPlacementEntity>? placeOrderResource,
    List<AddressEntity>? addresses, // <-- Changed from Resource<List<AddressEntity>>?
    String? selectedAddressId,
    PaymentMethodType? paymentMethod,
    bool? isGift,
    String? recipientName,
    String? recipientPhone,
  }) {
    return CheckoutState(
      checkoutDetailsResource:
      checkoutDetailsResource ?? this.checkoutDetailsResource,
      estimateDeliveryResource:
      estimateDeliveryResource ?? this.estimateDeliveryResource,
      placeOrderResource: placeOrderResource ?? this.placeOrderResource,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isGift: isGift ?? this.isGift,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      addresses: addresses ?? this.addresses,
    );
  }

  @override
  List<Object?> get props => [
    checkoutDetailsResource,
    estimateDeliveryResource,
    placeOrderResource,
    addresses, // <-- Added addresses to props
    selectedAddressId,
    paymentMethod,
    isGift,
    recipientName,
    recipientPhone,
  ];
}