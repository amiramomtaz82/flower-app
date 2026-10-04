import 'package:flower_app/features/orders/data/models/user_address_dto.dart';

import '../../../../core/app_constants/app_strings.dart';
import '../../domain/entities/order_tracking_entity.dart';
import '../../domain/entities/timeline_milestone_entity.dart';
import '../../domain/entities/tracking_steps_status.dart';
import '../../domain/entities/user_address_entity.dart';
import 'current_location_dto.dart';
import 'driver_dto.dart';

class OrderTrackingDto {
  OrderTrackingDto({
    this.orderId,
    this.status,
    this.isLive,
    this.driver,
    this.currentLocation,
    this.userAddress,
    this.estimatedDeliveryAt,
    this.awaitingCustomerConfirmation,
  });
  OrderTrackingDto.fromJson(dynamic json) {
    orderId = json['orderId'];
    status = json['status'];
    isLive = json['isLive'];
    driver = json['driver'] != null ? DriverDto.fromJson(json['driver']) : null;
    currentLocation = json['currentLocation'] != null
        ? CurrentLocation.fromJson(json['currentLocation'])
        : null;
    userAddress = json['userAddress'] != null
        ? UserAddress.fromJson(json['userAddress'])
        : null;
    estimatedDeliveryAt = json['estimatedDeliveryAt'];
    awaitingCustomerConfirmation = json['awaitingCustomerConfirmation'];
  }
  String? orderId;
  String? status;
  bool? isLive;
  DriverDto? driver;
  CurrentLocation? currentLocation;
  UserAddress? userAddress;
  String? estimatedDeliveryAt;
  bool? awaitingCustomerConfirmation;
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['orderId'] = orderId;
    map['status'] = status;
    map['isLive'] = isLive;
    if (driver != null) {
      map['driver'] = driver?.toJson();
    }
    if (currentLocation != null) {
      map['currentLocation'] = currentLocation?.toJson();
    }
    if (userAddress != null) {
      map['userAddress'] = userAddress?.toJson();
    }
    map['estimatedDeliveryAt'] = estimatedDeliveryAt;
    map['awaitingCustomerConfirmation'] = awaitingCustomerConfirmation;
    return map;
  }
  OrderTrackingEntity toEntity() {
    TrackingStepStatus parsedStatus;
    final normalized = (status ?? '').toLowerCase().replaceAll('_', '').replaceAll(' ', '');
    switch (normalized) {
      case 'preparing':
        parsedStatus = TrackingStepStatus.preparing;
        break;
      case 'pickup':
      case 'pickedup':
      case 'outfordelivery':
        parsedStatus = TrackingStepStatus.outForDelivery;
        break;
      case 'awaitingdeliveryconfirmation':
      case 'awaitingconfirmation':
        parsedStatus = TrackingStepStatus.awaitingConfirmation;
        break;
      case 'delivered':
        parsedStatus = TrackingStepStatus.delivered;
        break;
      case 'cancelled':
        parsedStatus = TrackingStepStatus.cancelled;
        break;
      default:
        parsedStatus = TrackingStepStatus.received;
    }
    final milestones = [
      const TimelineMilestoneEntity(
        title: AppStrings.orderReceived,
        timestamp: '03 Sep 2024 - 2:10',
        isCompleted: true,
      ),
      TimelineMilestoneEntity(
        title: AppStrings.orderPreparing,
        timestamp: '03 Sep 2024 - 2:25',
        isCompleted: parsedStatus.timelineIndex >= 1,
      ),
      TimelineMilestoneEntity(
        title: AppStrings.outForDelivery,
        timestamp: '03 Sep 2024 - 2:40',
        isCompleted: parsedStatus.timelineIndex >= 2,
      ),
      TimelineMilestoneEntity(
        title: AppStrings.delivered,
        timestamp: '03 Sep 2024 - 3:00',
        isCompleted: parsedStatus.timelineIndex >= 3,
      ),
    ];
    return OrderTrackingEntity(
      orderId: orderId ?? '',
      status: parsedStatus,
      isLive: isLive ?? false,
      awaitingCustomerConfirmation: awaitingCustomerConfirmation ?? false,
      estimatedDeliveryAt: DateTime.tryParse(estimatedDeliveryAt ?? ''),
      driver: driver?.toEntity(),
      currentLocation: currentLocation?.toEntity(),
      userAddress: userAddress?.toEntity() ??
          const UserAddressEntity(lat: 30.0444, lng: 31.2357, addressLine: ''),
      milestones: milestones,
    );
  }
}