import 'package:equatable/equatable.dart';
import 'package:flower_app/config/resource/rsource.dart';
import '../../domain/entities/order_tracking_entity.dart';

class OrderTrackingState extends Equatable {
  final Resource<OrderTrackingEntity> trackingResource;
  final Resource<bool> confirmationResource;
  final bool isStale;
  final bool showMap;
  final int secondsSinceLastSync;

  const OrderTrackingState({
    required this.trackingResource,
    required this.confirmationResource,
    this.isStale = false,
    this.showMap = false,
    this.secondsSinceLastSync = 0,
  });

  factory OrderTrackingState.initial() => OrderTrackingState(
    trackingResource: Resource.initial(),
    confirmationResource: Resource.initial(),
    isStale: false,
    showMap: false,
    secondsSinceLastSync: 0,
  );

  OrderTrackingState copyWith({
    Resource<OrderTrackingEntity>? trackingResource,
    Resource<bool>? confirmationResource,
    bool? isStale,
    bool? showMap,
    int? secondsSinceLastSync,
  }) {
    return OrderTrackingState(
      trackingResource: trackingResource ?? this.trackingResource,
      confirmationResource: confirmationResource ?? this.confirmationResource,
      isStale: isStale ?? this.isStale,
      showMap: showMap ?? this.showMap,
      secondsSinceLastSync: secondsSinceLastSync ?? this.secondsSinceLastSync,
    );
  }

  @override
  List<Object?> get props => [
    trackingResource,
    confirmationResource,
    isStale,
    showMap,
    secondsSinceLastSync,
  ];
}