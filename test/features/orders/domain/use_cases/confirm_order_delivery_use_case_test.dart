import 'package:flower_app/core/network/base_response.dart';
import 'package:flower_app/features/orders/domain/use_cases/confirm_order_delivery_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'get_orders_use_case_test.mocks.dart';

void main() {
  late ConfirmOrderDeliveryUseCase useCase;
  late MockOrderRepository mockOrderRepository;

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    useCase = ConfirmOrderDeliveryUseCase(mockOrderRepository);

    provideDummy<BaseResponse<bool>>(const SuccessResponse(true));
  });

  const tOrderId = 'test-order-123';

  group('ConfirmOrderDeliveryUseCase', () {
    test('should return true when repository confirms delivery successfully', () async {
      // arrange
      when(mockOrderRepository.confirmOrderDelivery(tOrderId))
          .thenAnswer((_) async => const SuccessResponse(true));

      // act
      final result = await useCase(tOrderId);

      // assert
      expect(result, isA<SuccessResponse<bool>>());
      expect((result as SuccessResponse<bool>).data, isTrue);
      verify(mockOrderRepository.confirmOrderDelivery(tOrderId)).called(1);
      verifyNoMoreInteractions(mockOrderRepository);
    });

    test('should return ErrorResponse when repository fails to confirm delivery', () async {
      // arrange
      when(mockOrderRepository.confirmOrderDelivery(tOrderId))
          .thenAnswer((_) async => ErrorResponse(errMessage: 'Confirmation failed'));

      // act
      final result = await useCase(tOrderId);

      // assert
      expect(result, isA<ErrorResponse<bool>>());
      expect((result as ErrorResponse<bool>).errMessage, equals('Confirmation failed'));
      verify(mockOrderRepository.confirmOrderDelivery(tOrderId)).called(1);
      verifyNoMoreInteractions(mockOrderRepository);
    });
  });
}
