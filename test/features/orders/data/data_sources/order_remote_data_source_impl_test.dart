import 'package:flower_app/features/orders/api/client/order_api_client.dart';
import 'package:flower_app/features/orders/data/data_sources/order_remote_data_source_impl.dart';
import 'package:flower_app/features/orders/data/models/order_model.dart';
import 'package:flower_app/features/orders/data/models/orders_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'order_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([OrderApiClient])
void main() {
  late OrderRemoteDataSourceImpl dataSource;
  late MockOrderApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockOrderApiClient();
    dataSource = OrderRemoteDataSourceImpl(mockApiClient);
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

  final mockResponse = OrdersResponseModel(
    orders: [mockOrderModel],
    pageNumber: pageNumber,
    pageSize: pageSize,
    totalCount: 1,
    totalPages: 1,
    hasNextPage: false,
    hasPreviousPage: false,
  );

  group('OrderRemoteDataSourceImpl.getOrders', () {
    test('returns OrdersResponseModel from api client on success', () async {
      when(mockApiClient.getOrders(pageNumber, pageSize))
          .thenAnswer((_) async => mockResponse);

      final result = await dataSource.getOrders(
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      expect(result, isA<OrdersResponseModel>());
      expect(result.orders.length, 1);
      expect(result.orders.first.id, '1');
      expect(result.pageNumber, pageNumber);
      expect(result.hasNextPage, false);

      verify(mockApiClient.getOrders(pageNumber, pageSize)).called(1);
      verifyNoMoreInteractions(mockApiClient);
    });

    test('passes correct pageNumber and pageSize to api client', () async {
      const customPage = 2;
      const customSize = 20;

      when(mockApiClient.getOrders(customPage, customSize)).thenAnswer(
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

      await dataSource.getOrders(pageNumber: customPage, pageSize: customSize);

      verify(mockApiClient.getOrders(customPage, customSize)).called(1);
    });

    test('propagates exception thrown by api client', () async {
      when(mockApiClient.getOrders(pageNumber, pageSize))
          .thenThrow(Exception('Network error'));

      expect(
        () => dataSource.getOrders(pageNumber: pageNumber, pageSize: pageSize),
        throwsA(isA<Exception>()),
      );
    });
  });
}
