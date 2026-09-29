import 'package:equatable/equatable.dart';

sealed class OrderTrackingEvent extends Equatable {
  const OrderTrackingEvent();

  @override
  List<Object?> get props => [];
}

class StartTrackingEvent extends OrderTrackingEvent {
  final String orderId;
  const StartTrackingEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class RefreshTrackingEvent extends OrderTrackingEvent {
  const RefreshTrackingEvent();
}

class ToggleMapEvent extends OrderTrackingEvent {
  final bool showMap;
  const ToggleMapEvent(this.showMap);

  @override
  List<Object?> get props => [showMap];
}

class FcmTrackingPayloadReceivedEvent extends OrderTrackingEvent {
  final Map<String, dynamic> payload;
  const FcmTrackingPayloadReceivedEvent(this.payload);

  @override
  List<Object?> get props => [payload];
}

class CheckStalenessTickEvent extends OrderTrackingEvent {
  const CheckStalenessTickEvent();
}

class ConfirmDeliveryPressedEvent extends OrderTrackingEvent {
  const ConfirmDeliveryPressedEvent();
}