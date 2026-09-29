import 'package:equatable/equatable.dart';
import '../../../../config/resource/rsource.dart';
import '../../domain/entities/order_tracking_entity.dart';

import '../../domain/oredr_details_entity.dart';

class OrderTrackingState extends Equatable {
  final Resource<OrderTrackingEntity> trackingResource;
  final Resource<bool> confirmationResource;

  final Resource<OrderDetailsEntity> orderDetailsResource;
  final bool isStale;
  final bool showMap;
  final int secondsSinceLastSync;

  const OrderTrackingState({
    required this.trackingResource,
    required this.confirmationResource,
    required this.orderDetailsResource,
    this.isStale = false,
    this.showMap = false,
    this.secondsSinceLastSync = 0,
  });

  factory OrderTrackingState.initial() => OrderTrackingState(
    trackingResource: Resource.initial(),
    confirmationResource: Resource.initial(),
    orderDetailsResource: Resource.initial(),
    isStale: false,
    showMap: false,
    secondsSinceLastSync: 0,
  );

  OrderTrackingState copyWith({
    Resource<OrderTrackingEntity>? trackingResource,
    Resource<bool>? confirmationResource,
    // 3. Change OrderModel to OrderDetailsEntity here in copyWith:
    Resource<OrderDetailsEntity>? orderDetailsResource,
    bool? isStale,
    bool? showMap,
    int? secondsSinceLastSync,
  }) {
    return OrderTrackingState(
      trackingResource: trackingResource ?? this.trackingResource,
      confirmationResource: confirmationResource ?? this.confirmationResource,
      orderDetailsResource: orderDetailsResource ?? this.orderDetailsResource,
      isStale: isStale ?? this.isStale,
      showMap: showMap ?? this.showMap,
      secondsSinceLastSync: secondsSinceLastSync ?? this.secondsSinceLastSync,
    );
  }

  @override
  List<Object?> get props => [
    trackingResource,
    confirmationResource,
    orderDetailsResource,
    isStale,
    showMap,
    secondsSinceLastSync,
  ];
}