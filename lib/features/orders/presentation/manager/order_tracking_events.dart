import 'package:equatable/equatable.dart';

import '../../domain/entities/order_tracking_update_entity.dart';

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



class CheckStalenessTickEvent extends OrderTrackingEvent {
  const CheckStalenessTickEvent();
}

class ConfirmDeliveryPressedEvent extends OrderTrackingEvent {
  const ConfirmDeliveryPressedEvent();
}
class TrackingUpdateReceivedEvent extends OrderTrackingEvent {
  final OrderTrackingUpdateEntity update;
  const TrackingUpdateReceivedEvent(this.update);
  @override
  List<Object?> get props => [update];
}