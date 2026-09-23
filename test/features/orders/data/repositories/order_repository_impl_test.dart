import 'package:flower_app/core/network/base_response.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/features/orders/data/data_sources/order_remote_data_source.dart';
import 'package:flower_app/features/orders/data/models/order_model.dart';
import 'package:flower_app/features/orders/data/models/orders_response_model.dart';
import 'package:flower_app/features/orders/data/repositories/order_repository_impl.dart';
import 'package:flower_app/features/orders/domain/entities/order_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'order_repository_impl_test.mocks.dart';

@GenerateMocks([OrderRemoteDataSource])
void main() {
  late OrderRepositoryImpl repository;
  late MockOrderRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockOrderRemoteDataSource();
    repository = OrderRepositoryImpl(mockDataSource);
  });

  const pageNumber = 1;
  const pageSize = 10;

  final mockOrderModel = OrderModel(
    id: '1',
    productName: 'Rose',
    imageUrl: 'https://example.com/rose.jpg',
    currency: 'EGP',
    price: 100.0,
    statusString: 'active',
    orderNumber: 1001,
    deliveredOn: null,
  );

  final mockResponseModel = OrdersResponseModel(
    orders: [mockOrderModel],
    pageNumber: pageNumber,
    pageSize: pageSize,
    totalCount: 1,
    totalPages: 1,
    hasNextPage: false,
    hasPreviousPage: false,
  );

  group('OrderRepositoryImpl.getOrders', () {
    test(
      'returns SuccessResponse with mapped entities when data source succeeds',
      () async {
        when(
          mockDataSource.getOrders(
            pageNumber: pageNumber,
            pageSize: pageSize,
          ),
        ).thenAnswer((_) async => mockResponseModel);

        final result = await repository.getOrders(
          pageNumber: pageNumber,
          pageSize: pageSize,
        );

        expect(result, isA<SuccessResponse<PaginatedResponse<OrderEntity>>>());
        final success = result as SuccessResponse<PaginatedResponse<OrderEntity>>;
        expect(success.data.data.length, 1);
        expect(success.data.data.first.id, '1');
        expect(success.data.data.first.productName, 'Rose');
        expect(success.data.data.first.status, OrderStatus.active);
        expect(success.data.pagination.page, pageNumber);
        expect(success.data.pagination.hasNextPage, false);

        verify(mockDataSource.getOrders(pageNumber: pageNumber, pageSize: pageSize)).called(1);
        verifyNoMoreInteractions(mockDataSource);
      },
    );

    test(
      'returns ErrorResponse when data source throws an exception',
      () async {
        when(
          mockDataSource.getOrders(pageNumber: pageNumber, pageSize: pageSize),
        ).thenThrow(Exception('Network error'));

        final result = await repository.getOrders(pageNumber: pageNumber, pageSize: pageSize);

        expect(result, isA<ErrorResponse<PaginatedResponse<OrderEntity>>>());
        verify(mockDataSource.getOrders(pageNumber: pageNumber, pageSize: pageSize)).called(1);
      },
    );

    test('passes correct pageNumber and pageSize to data source', () async {
      const customPage = 3;
      const customSize = 5;

      when(
        mockDataSource.getOrders(pageNumber: customPage, pageSize: customSize),
      ).thenAnswer(
        (_) async => const OrdersResponseModel(
          orders: [],
          pageNumber: customPage,
          pageSize: customSize,
          totalCount: 0,
          totalPages: 0,
          hasNextPage: false,
          hasPreviousPage: false,
        ),
      );

      await repository.getOrders(pageNumber: customPage, pageSize: customSize);

      verify(mockDataSource.getOrders(pageNumber: customPage, pageSize: customSize)).called(1);
    });
  });
}
