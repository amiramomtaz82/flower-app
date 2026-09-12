// lib/features/checkout/presentation/cubit/checkout_state.dart
import 'package:equatable/equatable.dart';

import '../../../../../config/resource/rsource.dart';
import '../../../Address/domain/entities/address_entity.dart';
import '../../domain/entities/checkout_details_entity.dart';
import '../../domain/entities/estimated_delivery_entity.dart';
import '../../domain/entities/oder_placment_entity.dart';

class CheckoutState extends Equatable {
  final Resource<CheckoutDetailsEntity> checkoutDetailsResource;
  final Resource<EstimateDeliveryEntity> estimateDeliveryResource;
  final Resource<OrderPlacementEntity> placeOrderResource;
  final List<AddressEntity> addresses;
  final String? selectedAddressId;
  final String? selectedPaymentMethod;
  final String? selectedPaymentGateway;
  final bool isGift;
  final String? recipientName;
  final String? recipientPhone;

  const CheckoutState({
    required this.checkoutDetailsResource,
    required this.estimateDeliveryResource,
    required this.placeOrderResource,
    required this.addresses,
    this.selectedAddressId,
    this.selectedPaymentMethod,
    this.selectedPaymentGateway,
    this.isGift = false,
    this.recipientName,
    this.recipientPhone,
  });

  factory CheckoutState.initial() => CheckoutState(
    checkoutDetailsResource: Resource.initial(),
    estimateDeliveryResource: Resource.initial(),
    placeOrderResource: Resource.initial(),
    addresses: const [],
    selectedAddressId: null,
    selectedPaymentMethod: null,
    selectedPaymentGateway: null,
    isGift: false,
    recipientName: null,
    recipientPhone: null,
  );

  // lib/features/checkout/presentation/cubit/checkout_state.dart

  CheckoutState copyWith({
    Resource<CheckoutDetailsEntity>? checkoutDetailsResource,
    Resource<EstimateDeliveryEntity>? estimateDeliveryResource,
    Resource<OrderPlacementEntity>? placeOrderResource,
    List<AddressEntity>? addresses,
    String? selectedAddressId,
    bool clearSelectedAddressId = false,
    String? selectedPaymentMethod,
    String? selectedPaymentGateway,
    bool clearPaymentGateway = false, // <--- Add this flag
    bool? isGift,
    String? recipientName,
    String? recipientPhone,
    bool clearRecipient = false,
  }) {
    return CheckoutState(
      checkoutDetailsResource:
      checkoutDetailsResource ?? this.checkoutDetailsResource,
      estimateDeliveryResource:
      estimateDeliveryResource ?? this.estimateDeliveryResource,
      placeOrderResource: placeOrderResource ?? this.placeOrderResource,
      addresses: addresses ?? this.addresses,
      selectedAddressId: clearSelectedAddressId
          ? null
          : (selectedAddressId ?? this.selectedAddressId),
      selectedPaymentMethod:
      selectedPaymentMethod ?? this.selectedPaymentMethod,
      selectedPaymentGateway: clearPaymentGateway
          ? null
          : (selectedPaymentGateway ?? this.selectedPaymentGateway), // <--- Use here
      isGift: isGift ?? this.isGift,
      recipientName: clearRecipient ? null : (recipientName ?? this.recipientName),
      recipientPhone: clearRecipient ? null : (recipientPhone ?? this.recipientPhone),
    );

  }

  @override
  List<Object?> get props => [
    checkoutDetailsResource,
    estimateDeliveryResource,
    placeOrderResource,
    addresses,
    selectedAddressId,
    selectedPaymentMethod,
    selectedPaymentGateway,
    isGift,
    recipientName,
    recipientPhone,
  ];
}