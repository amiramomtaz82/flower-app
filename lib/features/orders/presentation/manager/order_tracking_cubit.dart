import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/network/base_response.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import '../../domain/entities/current_location_entity.dart';
import '../../domain/entities/order_tracking_entity.dart';
import '../../domain/entities/timeline_milestone_entity.dart';
import '../../domain/entities/tracking_steps_status.dart';
import '../../domain/entities/user_address_entity.dart';
import '../../domain/oredr_details_entity.dart';
import '../../domain/use_cases/confirm_order_delivery_use_case.dart';
import '../../domain/use_cases/get_order_by_id_ue_case.dart';
import '../../domain/use_cases/get_order_tracking_use_case.dart';
import 'order_tracking_events.dart';
import 'order_tracking_states.dart';


@injectable
class OrderTrackingCubit extends Cubit<OrderTrackingState> {
  final GetOrderLiveTrackingUseCase _getLiveTrackingUseCase;
  final ConfirmOrderDeliveryUseCase _confirmOrderDeliveryUseCase;
  final GetOrderByIdUseCase _getOrderByIdUseCase;

  String? _currentOrderId;
  Timer? _pollingTimer;
  Timer? _stalenessTimer;
  DateTime? _lastSyncTimestamp;

  static const int staleThresholdSeconds = 45;
  static const int pollingIntervalSeconds = 5;

  OrderTrackingCubit(
      this._getLiveTrackingUseCase,
      this._confirmOrderDeliveryUseCase,
      this._getOrderByIdUseCase,
      ) : super(OrderTrackingState.initial());

  Future<void> doEvents(OrderTrackingEvent event) async {
    switch (event) {
      case StartTrackingEvent():
        _currentOrderId = event.orderId;
        await _fetchTracking(isInitial: true);
        _startPolling();
        _startStalenessTicker();

      case RefreshTrackingEvent():
        await _fetchTracking(isInitial: false);

      case ToggleMapEvent():
        emit(state.copyWith(showMap: event.showMap));

      case FcmTrackingPayloadReceivedEvent():
        _handleFcmPayload(event.payload);

      case CheckStalenessTickEvent():
        _evaluateStaleness();

      case ConfirmDeliveryPressedEvent():
        await _confirmDelivery();
    }
  }

  Future<void> _fetchTracking({required bool isInitial}) async {
    if (_currentOrderId == null) return;

    if (isInitial && !state.trackingResource.isSuccess) {
      emit(state.copyWith(trackingResource: Resource.loading()));
    }

    final result = await _getLiveTrackingUseCase(_currentOrderId!);

    switch (result) {
      case SuccessResponse<OrderTrackingEntity>():
        _lastSyncTimestamp = DateTime.now();
        emit(state.copyWith(
          trackingResource: Resource.success(result.data),
          isStale: result.data.currentLocation?.isStale ?? false,
          secondsSinceLastSync: 0,
        ));

        // When status is delivered or cancelled: stop timers only
        if (result.data.status == TrackingStepStatus.delivered ||
            result.data.status == TrackingStepStatus.cancelled) {
          _pollingTimer?.cancel();
          _stalenessTimer?.cancel();
        }

      case ErrorResponse<OrderTrackingEntity>():
        if (_isWaitingForDriverError(result.errMessage)) {
          // If already in waiting-for-driver state, keep state and do not mark stale
          if (state.trackingResource.isSuccess &&
              state.trackingResource.data != null &&
              state.trackingResource.data!.driver == null) {
            return;
          }
          final waitingEntity = await _buildWaitingForDriverEntity(_currentOrderId!);
          _lastSyncTimestamp = DateTime.now();
          emit(state.copyWith(
            trackingResource: Resource.success(waitingEntity),
            isStale: false,
            secondsSinceLastSync: 0,
          ));
        } else if (state.trackingResource.isSuccess) {
          if (state.trackingResource.data?.driver != null) {
            emit(state.copyWith(isStale: true));
          }
        } else {
          emit(state.copyWith(
            trackingResource: Resource.error(result.errMessage),
          ));
        }
    }
  }

  bool _isWaitingForDriverError(String? message) {
    if (message == null) return false;
    final lower = message.toLowerCase();
    return lower.contains('driver') ||
        lower.contains('accept') ||
        lower.contains('waiting') ||
        lower.contains('not assigned') ||
        lower.contains('unassigned') ||
        lower.contains('only available') ||
        lower.contains('سائق') ||
        lower.contains('قبول') ||
        lower.contains('تعيين');
  }

  Future<OrderTrackingEntity> _buildWaitingForDriverEntity(String orderId) async {
    UserAddressEntity address = const UserAddressEntity(
      lat: 30.0444,
      lng: 31.2357,
      addressLine: '',
    );

    try {
      final detailsRes = await _getOrderByIdUseCase(orderId);
      if (detailsRes is SuccessResponse<OrderDetailsEntity>) {
        address = UserAddressEntity(
          lat: 30.0444,
          lng: 31.2357,
          addressLine: detailsRes.data.addressDetail,
        );
      }
    } catch (_) {}

    final nowFormatted = DateFormat('dd MMM yyyy - hh:mm a').format(DateTime.now());

    final milestones = [
      TimelineMilestoneEntity(
        title: AppStrings.orderReceived,
        timestamp: nowFormatted,
        isCompleted: true,
      ),
      const TimelineMilestoneEntity(
        title: AppStrings.orderPreparing,
        timestamp: '--:--',
        isCompleted: false,
      ),
      const TimelineMilestoneEntity(
        title: AppStrings.outForDelivery,
        timestamp: '--:--',
        isCompleted: false,
      ),
      const TimelineMilestoneEntity(
        title: AppStrings.delivered,
        timestamp: '--:--',
        isCompleted: false,
      ),
    ];

    return OrderTrackingEntity(
      orderId: orderId,
      status: TrackingStepStatus.received,
      isLive: false,
      awaitingCustomerConfirmation: false,
      estimatedDeliveryAt: null,
      driver: null,
      currentLocation: null,
      userAddress: address,
      milestones: milestones,
    );
  }

  Future<void> _fetchOrderDetails(String orderId) async {
    emit(state.copyWith(orderDetailsResource: Resource.loading()));
    final result = await _getOrderByIdUseCase(orderId);
    switch (result) {
      case SuccessResponse<OrderDetailsEntity>():
        emit(state.copyWith(orderDetailsResource: Resource.success(result.data)));
      case ErrorResponse<OrderDetailsEntity>():
        emit(state.copyWith(orderDetailsResource: Resource.error(result.errMessage)));
    }
  }

  void _handleFcmPayload(Map<String, dynamic> payload) {
    if (_currentOrderId == null) return;
    if (payload['orderId'] != null && payload['orderId'] != _currentOrderId) return;

    final currentData = state.trackingResource.data;
    if (currentData != null) {
      final double? lat = double.tryParse(payload['lat']?.toString() ?? '');
      final double? lng = double.tryParse(payload['lng']?.toString() ?? '');

      CurrentLocationEntity? updatedLocation = currentData.currentLocation;
      if (lat != null && lng != null) {
        updatedLocation = (updatedLocation != null)
            ? updatedLocation.copyWith(lat: lat, lng: lng, recordedAt: DateTime.now(), isStale: false)
            : CurrentLocationEntity(lat: lat, lng: lng, recordedAt: DateTime.now(), isStale: false);
      }

      TrackingStepStatus updatedStatus = currentData.status;
      if (payload['status'] != null) {
        final st = payload['status'].toString().toLowerCase().replaceAll('_', '').replaceAll(' ', '');
        if (st == 'preparing') updatedStatus = TrackingStepStatus.preparing;
        if (st == 'pickup' || st == 'pickedup' || st == 'outfordelivery') updatedStatus = TrackingStepStatus.outForDelivery;
        if (st == 'awaitingdeliveryconfirmation' || st == 'awaitingconfirmation') updatedStatus = TrackingStepStatus.awaitingConfirmation;
        if (st == 'delivered') updatedStatus = TrackingStepStatus.delivered;
      }

      _lastSyncTimestamp = DateTime.now();

      emit(state.copyWith(
        trackingResource: Resource.success(
          currentData.copyWith(
            currentLocation: updatedLocation,
            status: updatedStatus,
            awaitingCustomerConfirmation:
            updatedStatus == TrackingStepStatus.awaitingConfirmation,
          ),
        ),
        isStale: false,
        secondsSinceLastSync: 0,
      ));

      if (updatedStatus == TrackingStepStatus.delivered) {
        _pollingTimer?.cancel();
        _stalenessTimer?.cancel();
        _fetchOrderDetails(_currentOrderId!);
      } else {
        _startPolling();
      }
    } else {
      _fetchTracking(isInitial: false);
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: pollingIntervalSeconds),
          (_) => doEvents(const RefreshTrackingEvent()),
    );
  }

  void _startStalenessTicker() {
    _stalenessTimer?.cancel();
    _stalenessTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => doEvents(const CheckStalenessTickEvent()),
    );
  }

  void _evaluateStaleness() {
    if (_lastSyncTimestamp == null || !state.trackingResource.isSuccess) return;

    final data = state.trackingResource.data;
    if (data == null || !data.isLive || data.driver == null) return;

    final diff = DateTime.now().difference(_lastSyncTimestamp!).inSeconds;
    final shouldBeStale = diff > staleThresholdSeconds;

    if (shouldBeStale != state.isStale || diff != state.secondsSinceLastSync) {
      emit(state.copyWith(
        isStale: shouldBeStale,
        secondsSinceLastSync: diff,
      ));
    }
  }

  Future<void> _confirmDelivery() async {
    if (_currentOrderId == null) return;
    emit(state.copyWith(confirmationResource: Resource.loading()));

    final result = await _confirmOrderDeliveryUseCase(_currentOrderId!);

    switch (result) {
      case SuccessResponse<bool>():
        emit(state.copyWith(confirmationResource: const Resource.success(true)));
        await _fetchTracking(isInitial: false);

      case ErrorResponse<bool>():
        emit(state.copyWith(
          confirmationResource: Resource.error(result.errMessage),
        ));
    }
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    _stalenessTimer?.cancel();
    return super.close();
  }
}