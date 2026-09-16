import 'package:bloc_test/bloc_test.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/features/orders/domain/entities/order_entity.dart';
import 'package:flower_app/features/orders/domain/use_cases/get_orders_use_case.dart';
import 'package:flower_app/features/orders/presentation/manager/my_orders_cubit.dart';
import 'package:flower_app/features/orders/presentation/manager/my_orders_events.dart';
import 'package:flower_app/features/orders/presentation/manager/my_orders_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'my_orders_cubit_test.mocks.dart';

@GenerateMocks([GetOrdersUseCase])
void main() {
  late MyOrdersCubit cubit;
  late MockGetOrdersUseCase mockGetOrdersUseCase;

  setUp(() {
    mockGetOrdersUseCase = MockGetOrdersUseCase();
    cubit = MyOrdersCubit(mockGetOrdersUseCase);
  });

  tearDown(() {
    cubit.close();
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

  group('MyOrdersCubit', () {
    test('initial state should be initial', () {
      expect(cubit.state.orders.status, ApiStatus.initial);
    });

    blocTest<MyOrdersCubit, MyOrdersState>(
      'emits [loading, success] when MyOrdersStarted is added and use case succeeds',
      build: () {
        when(mockGetOrdersUseCase.call()).thenAnswer((_) async => mockOrders);
        return cubit;
      },
      act: (cubit) => cubit.doEvents(MyOrdersStarted()),
      expect: () => [
        isA<MyOrdersState>().having((s) => s.orders.status, 'status', ApiStatus.loading),
        isA<MyOrdersState>()
            .having((s) => s.orders.status, 'status', ApiStatus.success)
            .having((s) => s.orders.data, 'data', mockOrders),
      ],
      verify: (_) {
        verify(mockGetOrdersUseCase.call()).called(1);
      },
    );

    blocTest<MyOrdersCubit, MyOrdersState>(
      'emits [loading, error] when MyOrdersStarted is added and use case fails',
      build: () {
        when(mockGetOrdersUseCase.call()).thenThrow(Exception('Failed'));
        return cubit;
      },
      act: (cubit) => cubit.doEvents(MyOrdersStarted()),
      expect: () => [
        isA<MyOrdersState>().having((s) => s.orders.status, 'status', ApiStatus.loading),
        isA<MyOrdersState>()
            .having((s) => s.orders.status, 'status', ApiStatus.error)
            .having((s) => s.orders.errorMessage, 'errorMessage', 'Exception: Failed'),
      ],
    );
  });
}
