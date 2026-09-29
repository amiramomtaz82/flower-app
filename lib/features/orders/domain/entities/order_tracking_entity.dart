import 'package:equatable/equatable.dart';
import 'package:flower_app/features/orders/domain/entities/timeline_milestone_entity.dart';
import 'package:flower_app/features/orders/domain/entities/tracking_steps_status.dart';
import 'package:flower_app/features/orders/domain/entities/user_address_entity.dart';

import 'current_location_entity.dart';
import 'driver_entity.dart';

class OrderTrackingEntity extends Equatable {
  final String orderId;
  final TrackingStepStatus status;
  final bool isLive;
  final bool awaitingCustomerConfirmation;
  final DateTime? estimatedDeliveryAt;
  final DriverEntity? driver;
  final CurrentLocationEntity? currentLocation;
  final UserAddressEntity userAddress;
  final List<TimelineMilestoneEntity> milestones;
  const OrderTrackingEntity({
    required this.orderId,
    required this.status,
    required this.isLive,
    required this.awaitingCustomerConfirmation,
    this.estimatedDeliveryAt,
    this.driver,
    this.currentLocation,
    required this.userAddress,
    required this.milestones,
  });
  OrderTrackingEntity copyWith({
    TrackingStepStatus? status,
    bool? isLive,
    bool? awaitingCustomerConfirmation,
    DateTime? estimatedDeliveryAt,
    DriverEntity? driver,
    CurrentLocationEntity? currentLocation,
    List<TimelineMilestoneEntity>? milestones,
  }) {
    return OrderTrackingEntity(
      orderId: orderId,
      status: status ?? this.status,
      isLive: isLive ?? this.isLive,
      awaitingCustomerConfirmation:
      awaitingCustomerConfirmation ?? this.awaitingCustomerConfirmation,
      estimatedDeliveryAt: estimatedDeliveryAt ?? this.estimatedDeliveryAt,
      driver: driver ?? this.driver,
      currentLocation: currentLocation ?? this.currentLocation,
      userAddress: userAddress,
      milestones: milestones ?? this.milestones,
    );
  }
  @override
  List<Object?> get props => [
    orderId,
    status,
    isLive,
    awaitingCustomerConfirmation,
    estimatedDeliveryAt,
    driver,
    currentLocation,
    userAddress,
    milestones,
  ];
}