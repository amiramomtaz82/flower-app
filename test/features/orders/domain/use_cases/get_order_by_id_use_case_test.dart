import 'package:flower_app/core/network/base_response.dart';
import 'package:flower_app/features/orders/domain/entities/order_item_entity.dart';
import 'package:flower_app/features/orders/domain/oredr_details_entity.dart';
import 'package:flower_app/features/orders/domain/use_cases/get_order_by_id_ue_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'get_orders_use_case_test.mocks.dart';

void main() {
  late GetOrderByIdUseCase useCase;
  late MockOrderRepository mockOrderRepository;

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    useCase = GetOrderByIdUseCase(mockOrderRepository);

    provideDummy<BaseResponse<OrderDetailsEntity>>(
      const SuccessResponse(
        OrderDetailsEntity(
          orderId: '123',
          customerName: 'Nour',
          addressTitle: 'Home',
          addressDetail: 'Sheikh Zayed',
          paymentMethod: 'Cash',
          currency: 'EGP',
          subTotal: 1000,
          deliveryFee: 105,
          total: 1105,
          items: [],
        ),
      ),
    );
  });

  const tOrderId = 'test-order-123';
  const tOrderDetails = OrderDetailsEntity(
    orderId: tOrderId,
    customerName: 'Nour',
    addressTitle: 'Home',
    addressDetail: '269VP+Q2 - Sheikh Zayed',
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

  group('GetOrderByIdUseCase', () {
    test('should return OrderDetailsEntity when repository call succeeds', () async {
      // arrange
      when(mockOrderRepository.getOrderById(tOrderId))
          .thenAnswer((_) async => const SuccessResponse(tOrderDetails));

      // act
      final result = await useCase(tOrderId);

      // assert
      expect(result, isA<SuccessResponse<OrderDetailsEntity>>());
      expect((result as SuccessResponse<OrderDetailsEntity>).data, equals(tOrderDetails));
      verify(mockOrderRepository.getOrderById(tOrderId)).called(1);
      verifyNoMoreInteractions(mockOrderRepository);
    });

    test('should return ErrorResponse when repository call fails', () async {
      // arrange
      when(mockOrderRepository.getOrderById(tOrderId))
          .thenAnswer((_) async => ErrorResponse(errMessage: 'Order not found'));

      // act
      final result = await useCase(tOrderId);

      // assert
      expect(result, isA<ErrorResponse<OrderDetailsEntity>>());
      expect((result as ErrorResponse<OrderDetailsEntity>).errMessage, equals('Order not found'));
      verify(mockOrderRepository.getOrderById(tOrderId)).called(1);
      verifyNoMoreInteractions(mockOrderRepository);
    });
  });
}
