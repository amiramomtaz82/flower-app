import 'package:equatable/equatable.dart';
import 'current_location_entity.dart';
import 'tracking_steps_status.dart';

class OrderTrackingUpdateEntity extends Equatable {
  final String orderId;
  final TrackingStepStatus? status;
  final CurrentLocationEntity? currentLocation;

  const OrderTrackingUpdateEntity({
    required this.orderId,
    this.status,
    this.currentLocation,
  });

  @override
  List<Object?> get props => [orderId, status, currentLocation];
}