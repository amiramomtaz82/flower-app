import 'package:flower_app/core/network/base_response.dart';
import 'package:flower_app/features/orders/domain/entities/order_tracking_entity.dart';
import 'package:flower_app/features/orders/domain/entities/tracking_steps_status.dart';
import 'package:flower_app/features/orders/domain/entities/user_address_entity.dart';
import 'package:flower_app/features/orders/domain/use_cases/get_order_tracking_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'get_orders_use_case_test.mocks.dart';

void main() {
  late GetOrderLiveTrackingUseCase useCase;
  late MockOrderRepository mockOrderRepository;

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    useCase = GetOrderLiveTrackingUseCase(mockOrderRepository);

    provideDummy<BaseResponse<OrderTrackingEntity>>(
      const SuccessResponse(
        OrderTrackingEntity(
          orderId: '123',
          status: TrackingStepStatus.outForDelivery,
          isLive: true,
          awaitingCustomerConfirmation: false,
          userAddress: UserAddressEntity(lat: 30.0, lng: 31.0, addressLine: 'Test'),
          milestones: [],
        ),
      ),
    );
  });

  const tOrderId = 'test-order-123';
  const tTrackingEntity = OrderTrackingEntity(
    orderId: tOrderId,
    status: TrackingStepStatus.outForDelivery,
    isLive: true,
    awaitingCustomerConfirmation: false,
    userAddress: UserAddressEntity(lat: 30.0444, lng: 31.2357, addressLine: '123 Test St'),
    milestones: [],
  );

  group('GetOrderLiveTrackingUseCase', () {
    test('should return OrderTrackingEntity when repository call is successful', () async {
      // arrange
      when(mockOrderRepository.getLiveTracking(tOrderId))
          .thenAnswer((_) async => const SuccessResponse(tTrackingEntity));

      // act
      final result = await useCase(tOrderId);

      // assert
      expect(result, isA<SuccessResponse<OrderTrackingEntity>>());
      expect((result as SuccessResponse<OrderTrackingEntity>).data, equals(tTrackingEntity));
      verify(mockOrderRepository.getLiveTracking(tOrderId)).called(1);
      verifyNoMoreInteractions(mockOrderRepository);
    });

    test('should return ErrorResponse when repository call fails', () async {
      // arrange
      when(mockOrderRepository.getLiveTracking(tOrderId))
          .thenAnswer((_) async => ErrorResponse(errMessage: 'Network failure'));

      // act
      final result = await useCase(tOrderId);

      // assert
      expect(result, isA<ErrorResponse<OrderTrackingEntity>>());
      expect((result as ErrorResponse<OrderTrackingEntity>).errMessage, equals('Network failure'));
      verify(mockOrderRepository.getLiveTracking(tOrderId)).called(1);
      verifyNoMoreInteractions(mockOrderRepository);
    });
  });
}
