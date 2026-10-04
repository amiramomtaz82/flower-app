import 'package:bloc_test/bloc_test.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/network/base_response.dart';
import 'package:flower_app/features/orders/domain/entities/current_location_entity.dart';
import 'package:flower_app/features/orders/domain/entities/driver_entity.dart';
import 'package:flower_app/features/orders/domain/entities/order_item_entity.dart';
import 'package:flower_app/features/orders/domain/entities/order_tracking_entity.dart';
import 'package:flower_app/features/orders/domain/entities/tracking_steps_status.dart';
import 'package:flower_app/features/orders/domain/entities/user_address_entity.dart';
import 'package:flower_app/features/orders/domain/oredr_details_entity.dart';
import 'package:flower_app/features/orders/presentation/manager/order_tracking_cubit.dart';
import 'package:flower_app/features/orders/presentation/manager/order_tracking_events.dart';
import 'package:flower_app/features/orders/presentation/manager/order_tracking_states.dart';
import 'package:flower_app/features/orders/domain/use_cases/confirm_order_delivery_use_case.dart';
import 'package:flower_app/features/orders/domain/use_cases/get_order_by_id_ue_case.dart';
import 'package:flower_app/features/orders/domain/use_cases/get_order_tracking_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'order_tracking_cubit_test.mocks.dart';

@GenerateMocks([
  GetOrderLiveTrackingUseCase,
  ConfirmOrderDeliveryUseCase,
  GetOrderByIdUseCase,
])
void main() {
  late OrderTrackingCubit cubit;
  late MockGetOrderLiveTrackingUseCase mockGetOrderLiveTrackingUseCase;
  late MockConfirmOrderDeliveryUseCase mockConfirmOrderDeliveryUseCase;
  late MockGetOrderByIdUseCase mockGetOrderByIdUseCase;

  const tOrderId = 'test-order-123';

  final tDriver = const DriverEntity(
    driverId: 'driver-1',
    name: 'Mohamed',
    phone: '+201012345678',
  );

  final tAddress = const UserAddressEntity(
    lat: 30.0444,
    lng: 31.2357,
    addressLine: '123 Test St',
  );

  final tLocation = CurrentLocationEntity(
    lat: 30.0488,
    lng: 31.2330,
    recordedAt: DateTime.now(),
    isStale: false,
  );

  final tTrackingEntity = OrderTrackingEntity(
    orderId: tOrderId,
    status: TrackingStepStatus.outForDelivery,
    isLive: true,
    awaitingCustomerConfirmation: false,
    driver: tDriver,
    currentLocation: tLocation,
    userAddress: tAddress,
    milestones: const [],
  );

  final tDeliveredTrackingEntity = OrderTrackingEntity(
    orderId: tOrderId,
    status: TrackingStepStatus.delivered,
    isLive: false,
    awaitingCustomerConfirmation: false,
    driver: tDriver,
    currentLocation: tLocation,
    userAddress: tAddress,
    milestones: const [],
  );

  const tOrderDetails = OrderDetailsEntity(
    orderId: tOrderId,
    customerName: 'Nour',
    addressTitle: 'Home',
    addressDetail: '123 Test St',
    paymentMethod: 'Pay with cash',
    currency: 'EGP',
    subTotal: 1000,
    deliveryFee: 105,
    total: 1105,
    items: [
      OrderItemEntity(
        id: '1',
        productName: 'Red roses',
        description: '18 Pink Rose Bouquet',
        price: 600,
        quantity: 1,
      ),
    ],
  );

  setUp(() {
    mockGetOrderLiveTrackingUseCase = MockGetOrderLiveTrackingUseCase();
    mockConfirmOrderDeliveryUseCase = MockConfirmOrderDeliveryUseCase();
    mockGetOrderByIdUseCase = MockGetOrderByIdUseCase();

    provideDummy<BaseResponse<OrderTrackingEntity>>(
      SuccessResponse(tTrackingEntity),
    );
    provideDummy<BaseResponse<bool>>(
      const SuccessResponse(true),
    );
    provideDummy<BaseResponse<OrderDetailsEntity>>(
      const SuccessResponse(tOrderDetails),
    );

    cubit = OrderTrackingCubit(
      mockGetOrderLiveTrackingUseCase,
      mockConfirmOrderDeliveryUseCase,
      mockGetOrderByIdUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('OrderTrackingCubit', () {
    test('initial state should have initial resources and default toggles', () {
      expect(cubit.state.trackingResource.status, ApiStatus.initial);
      expect(cubit.state.confirmationResource.status, ApiStatus.initial);
      expect(cubit.state.orderDetailsResource.status, ApiStatus.initial);
      expect(cubit.state.showMap, isFalse);
      expect(cubit.state.isStale, isFalse);
    });

    blocTest<OrderTrackingCubit, OrderTrackingState>(
      'emits [loading, success] when StartTrackingEvent succeeds',
      build: () {
        when(mockGetOrderLiveTrackingUseCase.call(tOrderId))
            .thenAnswer((_) async => SuccessResponse(tTrackingEntity));
        return cubit;
      },
      act: (cubit) => cubit.doEvents(const StartTrackingEvent(tOrderId)),
      expect: () => [
        isA<OrderTrackingState>()
            .having((s) => s.trackingResource.isLoading, 'isLoading', isTrue),
        isA<OrderTrackingState>()
            .having((s) => s.trackingResource.isSuccess, 'isSuccess', isTrue)
            .having((s) => s.trackingResource.data, 'data', tTrackingEntity)
            .having((s) => s.isStale, 'isStale', isFalse),
      ],
      verify: (_) {
        verify(mockGetOrderLiveTrackingUseCase.call(tOrderId)).called(1);
      },
    );

    blocTest<OrderTrackingCubit, OrderTrackingState>(
      'emits [loading, error] when StartTrackingEvent fails',
      build: () {
        when(mockGetOrderLiveTrackingUseCase.call(tOrderId))
            .thenAnswer((_) async => ErrorResponse(errMessage: 'Connection error'));
        return cubit;
      },
      act: (cubit) => cubit.doEvents(const StartTrackingEvent(tOrderId)),
      expect: () => [
        isA<OrderTrackingState>()
            .having((s) => s.trackingResource.isLoading, 'isLoading', isTrue),
        isA<OrderTrackingState>()
            .having((s) => s.trackingResource.isError, 'isError', isTrue)
            .having((s) => s.trackingResource.errorMessage, 'errMessage', 'Connection error'),
      ],
    );

    blocTest<OrderTrackingCubit, OrderTrackingState>(
      'emits tracking data without calling order details when tracking status is delivered',
      build: () {
        when(mockGetOrderLiveTrackingUseCase.call(tOrderId))
            .thenAnswer((_) async => SuccessResponse(tDeliveredTrackingEntity));
        return cubit;
      },
      act: (cubit) => cubit.doEvents(const StartTrackingEvent(tOrderId)),
      expect: () => [
        isA<OrderTrackingState>()
            .having((s) => s.trackingResource.isLoading, 'isLoading', isTrue),
        isA<OrderTrackingState>()
            .having((s) => s.trackingResource.isSuccess, 'isSuccess', isTrue)
            .having((s) => s.trackingResource.data?.status, 'status', TrackingStepStatus.delivered),
      ],
      verify: (_) {
        verify(mockGetOrderLiveTrackingUseCase.call(tOrderId)).called(1);
        verifyNever(mockGetOrderByIdUseCase.call(any));
      },
    );

    blocTest<OrderTrackingCubit, OrderTrackingState>(
      'emits updated showMap when ToggleMapEvent is added',
      build: () => cubit,
      act: (cubit) {
        cubit.doEvents(const ToggleMapEvent(true));
        cubit.doEvents(const ToggleMapEvent(false));
      },
      expect: () => [
        isA<OrderTrackingState>().having((s) => s.showMap, 'showMap', isTrue),
        isA<OrderTrackingState>().having((s) => s.showMap, 'showMap', isFalse),
      ],
    );

    blocTest<OrderTrackingCubit, OrderTrackingState>(
      'confirms delivery and refetches tracking on ConfirmDeliveryPressedEvent',
      build: () {
        when(mockGetOrderLiveTrackingUseCase.call(tOrderId))
            .thenAnswer((_) async => SuccessResponse(tTrackingEntity));
        when(mockConfirmOrderDeliveryUseCase.call(tOrderId))
            .thenAnswer((_) async => const SuccessResponse(true));
        return cubit;
      },
      act: (cubit) async {
        await cubit.doEvents(const StartTrackingEvent(tOrderId));
        await cubit.doEvents(const ConfirmDeliveryPressedEvent());
      },
      skip: 2, // Skip initial StartTrackingEvent emissions
      expect: () => [
        isA<OrderTrackingState>()
            .having((s) => s.confirmationResource.isLoading, 'confirmation.isLoading', isTrue),
        isA<OrderTrackingState>()
            .having((s) => s.confirmationResource.isSuccess, 'confirmation.isSuccess', isTrue),
      ],
      verify: (_) {
        verify(mockConfirmOrderDeliveryUseCase.call(tOrderId)).called(1);
        verify(mockGetOrderLiveTrackingUseCase.call(tOrderId)).called(2);
      },
    );

    blocTest<OrderTrackingCubit, OrderTrackingState>(
      'emits [loading, success] with waiting-for-driver entity when tracking is awaiting driver acceptance',
      build: () {
        when(mockGetOrderLiveTrackingUseCase.call(tOrderId))
            .thenAnswer((_) async => ErrorResponse(
                  errMessage: 'Tracking is only available once a driver accepts the order.',
                ));
        when(mockGetOrderByIdUseCase.call(tOrderId))
            .thenAnswer((_) async => const SuccessResponse(tOrderDetails));
        return cubit;
      },
      act: (cubit) => cubit.doEvents(const StartTrackingEvent(tOrderId)),
      expect: () => [
        isA<OrderTrackingState>()
            .having((s) => s.trackingResource.isLoading, 'isLoading', isTrue),
        isA<OrderTrackingState>()
            .having((s) => s.trackingResource.isSuccess, 'isSuccess', isTrue)
            .having((s) => s.trackingResource.data?.driver, 'driver', isNull)
            .having((s) => s.trackingResource.data?.status, 'status', TrackingStepStatus.received)
            .having((s) => s.trackingResource.data?.isLive, 'isLive', isFalse)
            .having((s) => s.isStale, 'isStale', isFalse),
      ],
      verify: (_) {
        verify(mockGetOrderLiveTrackingUseCase.call(tOrderId)).called(1);
      },
    );
  });
}
