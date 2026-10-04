import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/features/orders/data/models/user_address_dto.dart';

import '../../../../core/app_constants/app_strings.dart';
import '../../domain/entities/order_tracking_entity.dart';
import '../../domain/entities/timeline_milestone_entity.dart';
import '../../domain/entities/tracking_steps_status.dart';
import '../../domain/entities/user_address_entity.dart';
import 'current_location_dto.dart';
import 'driver_dto.dart';

class OrderTrackingDto {
  String? orderId;
  String? status;
  bool? isLive;
  DriverDto? driver;
  CurrentLocation? currentLocation;
  UserAddress? userAddress;
  String? estimatedDeliveryAt;
  bool? awaitingCustomerConfirmation;
  String? createdAt;
  String? assignedAt;
  String? deliveredAt;
  List<TimelineMilestoneEntity>? backendMilestones;

  OrderTrackingDto({
    this.orderId,
    this.status,
    this.isLive,
    this.driver,
    this.currentLocation,
    this.userAddress,
    this.estimatedDeliveryAt,
    this.awaitingCustomerConfirmation,
    this.createdAt,
    this.assignedAt,
    this.deliveredAt,
    this.backendMilestones,
  });

  OrderTrackingDto.fromJson(dynamic json) {
    orderId = json['orderId']?.toString();
    status = json['status']?.toString();
    isLive = json['isLive'];
    driver = json['driver'] != null ? DriverDto.fromJson(json['driver']) : null;
    currentLocation = json['currentLocation'] != null
        ? CurrentLocation.fromJson(json['currentLocation'])
        : null;
    userAddress = json['userAddress'] != null
        ? UserAddress.fromJson(json['userAddress'])
        : null;
    estimatedDeliveryAt = json['estimatedDeliveryAt']?.toString();
    awaitingCustomerConfirmation = json['awaitingCustomerConfirmation'];
    createdAt = json['createdAt']?.toString() ?? json['placedAt']?.toString();
    assignedAt = json['assignedAt']?.toString();
    deliveredAt = json['deliveredAt']?.toString();

    if (json['milestones'] is List) {
      final list = json['milestones'] as List;
      backendMilestones = list.map((m) {
        final title = m['title']?.toString() ?? '';
        final ts = m['timestamp']?.toString() ?? '--:--';
        final isDone = m['isCompleted'] == true;
        return TimelineMilestoneEntity(
          title: title,
          timestamp: ts,
          isCompleted: isDone,
        );
      }).toList();
    }
  }

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
    if (createdAt != null) map['createdAt'] = createdAt;
    if (assignedAt != null) map['assignedAt'] = assignedAt;
    if (deliveredAt != null) map['deliveredAt'] = deliveredAt;
    return map;
  }

  OrderTrackingEntity toEntity() {
    TrackingStepStatus parsedStatus;
    final normalized =
        (status ?? '').toLowerCase().replaceAll('_', '').replaceAll(' ', '');
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

    final parsedEstimated = DateTime.tryParse(estimatedDeliveryAt ?? '');
    final parsedCreated = DateTime.tryParse(createdAt ?? '');
    final parsedAssigned = DateTime.tryParse(assignedAt ?? '');
    final parsedDelivered = DateTime.tryParse(deliveredAt ?? '');

    String formatDateTime(DateTime? dt) {
      if (dt == null) return '--:--';
      return DateFormat('dd MMM, hh:mm a').format(dt.toLocal());
    }

    final isReceivedDone = true;
    final isPreparingDone = parsedStatus.timelineIndex >= 1;
    final isDeliveryDone = parsedStatus.timelineIndex >= 2;
    final isDeliveredDone = parsedStatus.timelineIndex >= 3;

    final receivedTime = parsedCreated != null
        ? formatDateTime(parsedCreated)
        : '--:--';

    final preparingTime = parsedAssigned != null && isPreparingDone
        ? formatDateTime(parsedAssigned)
        : '--:--';

    final outForDeliveryTime = parsedAssigned != null && isDeliveryDone
        ? formatDateTime(parsedAssigned)
        : '--:--';

    final deliveredTime = isDeliveredDone
        ? (parsedDelivered != null ? formatDateTime(parsedDelivered) : '--:--')
        : (parsedEstimated != null ? formatDateTime(parsedEstimated) : '--:--');

    final milestones = backendMilestones ??
        [
          TimelineMilestoneEntity(
            title: AppStrings.orderReceived,
            timestamp: receivedTime,
            isCompleted: isReceivedDone,
          ),
          TimelineMilestoneEntity(
            title: AppStrings.orderPreparing,
            timestamp: preparingTime,
            isCompleted: isPreparingDone,
          ),
          TimelineMilestoneEntity(
            title: AppStrings.outForDelivery,
            timestamp: outForDeliveryTime,
            isCompleted: isDeliveryDone,
          ),
          TimelineMilestoneEntity(
            title: AppStrings.delivered,
            timestamp: deliveredTime,
            isCompleted: isDeliveredDone,
          ),
        ];

    return OrderTrackingEntity(
      orderId: orderId ?? '',
      status: parsedStatus,
      isLive: isLive ?? false,
      awaitingCustomerConfirmation: awaitingCustomerConfirmation ?? false,
      estimatedDeliveryAt: parsedEstimated,
      driver: driver?.toEntity(),
      currentLocation: currentLocation?.toEntity(),
      userAddress: userAddress?.toEntity() ??
          const UserAddressEntity(lat: 30.0444, lng: 31.2357, addressLine: ''),
      milestones: milestones,
    );
  }
}