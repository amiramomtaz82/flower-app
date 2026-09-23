import 'package:flower_app/features/orders/domain/entities/order_entity.dart';
import 'package:flower_app/features/orders/domain/repositories/order_repository.dart';
import 'package:flower_app/features/orders/domain/use_cases/get_orders_use_case.dart';
import 'package:flower_app/core/network/base_response.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/core/pagination/pagination_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_orders_use_case_test.mocks.dart';

@GenerateMocks([OrderRepository])
void main() {
  late GetOrdersUseCase useCase;
  late MockOrderRepository mockOrderRepository;

  setUp(() {
    mockOrderRepository = MockOrderRepository();
    useCase = GetOrdersUseCase(mockOrderRepository);
    // Provide a dummy for the sealed BaseResponse so Mockito can generate stubs
    provideDummy<BaseResponse<PaginatedResponse<OrderEntity>>>(
      SuccessResponse(PaginatedResponse<OrderEntity>(
        data: const [],
        pagination: PaginationModel(),
      )),
    );
  });

  final mockOrders = [
    const OrderEntity(
      id: '1',
      productName: 'Rose',
      imageUrl: '',
      currency: 'EGP',
      price: 100,
      status: OrderStatus.active,
    )
  ];

  final mockResponse = SuccessResponse(PaginatedResponse<OrderEntity>(
    data: mockOrders,
    pagination: PaginationModel(page: 1, pageSize: 10, totalCount: 1, totalPages: 1, hasNextPage: false, hasPreviousPage: false),
  ));

  test('should get orders from the repository', () async {
    // arrange
    when(mockOrderRepository.getOrders(pageNumber: 1, pageSize: 10))
        .thenAnswer((_) async => mockResponse);

    // act
    final result = await useCase(pageNumber: 1, pageSize: 10);

    // assert
    expect(result, mockResponse);
    verify(mockOrderRepository.getOrders(pageNumber: 1, pageSize: 10));
    verifyNoMoreInteractions(mockOrderRepository);
  });
}
