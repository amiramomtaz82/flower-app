import '../../domain/entities/current_location_entity.dart';
import '../../domain/entities/order_tracking_update_entity.dart';
import '../../domain/entities/tracking_steps_status.dart';

class OrderTrackingUpdateDto {
  final String? orderId;
  final String? status;
  final double? lat;
  final double? lng;

  const OrderTrackingUpdateDto({
    this.orderId,
    this.status,
    this.lat,
    this.lng,
  });

  factory OrderTrackingUpdateDto.fromPayload(Map<String, dynamic> payload) {
    return OrderTrackingUpdateDto(
      orderId: payload['orderId']?.toString(),
      status: payload['status']?.toString(),
      lat: double.tryParse(payload['lat']?.toString() ?? ''),
      lng: double.tryParse(payload['lng']?.toString() ?? ''),
    );
  }

  OrderTrackingUpdateEntity toEntity() {
    TrackingStepStatus? parsedStatus;
    if (status != null) {
      final st = status!.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
      if (st == 'preparing') {
        parsedStatus = TrackingStepStatus.preparing;
      } else if (st == 'pickup' || st == 'pickedup') {
        parsedStatus = TrackingStepStatus.pickedUp; // Separate picked up status
      } else if (st == 'outfordelivery') {
        parsedStatus = TrackingStepStatus.outForDelivery;
      } else if (st == 'awaitingdeliveryconfirmation' ||
          st == 'awaitingconfirmation') {
        parsedStatus = TrackingStepStatus.awaitingDeliveryConfirmation; // Matches enum
      } else if (st == 'delivered') {
        parsedStatus = TrackingStepStatus.delivered;
      } else if (st == 'cancelled') {
        parsedStatus = TrackingStepStatus.cancelled;
      } else if (st == 'received') {
        parsedStatus = TrackingStepStatus.received;
      }
    }

    CurrentLocationEntity? location;
    if (lat != null && lng != null) {
      location = CurrentLocationEntity(
        lat: lat!,
        lng: lng!,
        recordedAt: DateTime.now(),
        isStale: false,
      );
    }

    return OrderTrackingUpdateEntity(
      orderId: orderId ?? '',
      status: parsedStatus,
      currentLocation: location,
    );
  }
}