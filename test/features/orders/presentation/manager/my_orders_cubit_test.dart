import 'package:bloc_test/bloc_test.dart';
import 'package:flower_app/core/network/base_response.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/core/pagination/pagination_model.dart';
import 'package:flower_app/core/pagination/pagination_state.dart';
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
    // Provide a dummy for the sealed BaseResponse so Mockito can generate stubs
    provideDummy<BaseResponse<PaginatedResponse<OrderEntity>>>(
      SuccessResponse(PaginatedResponse<OrderEntity>(
        data: const [],
        pagination: PaginationModel(),
      )),
    );
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
      expect(cubit.state.paginationState.resource.status, ApiStatus.initial);
    });

    blocTest<MyOrdersCubit, MyOrdersState>(
      'emits success state with data when MyOrdersStarted is added and use case succeeds',
      build: () {
        when(mockGetOrdersUseCase.call(pageNumber: anyNamed('pageNumber'), pageSize: anyNamed('pageSize'))).thenAnswer((_) async => SuccessResponse(PaginatedResponse<OrderEntity>(
          data: mockOrders,
          pagination: PaginationModel(page: 1, pageSize: 10, totalCount: 1, totalPages: 1, hasNextPage: false, hasPreviousPage: false),
        )));
        return cubit;
      },
      act: (cubit) => cubit.doEvents(MyOrdersStarted()),
      expect: () => [
        // PaginationController mutates its internal state and the cubit emits
        // once: either a loading-then-resolved state or the final state.
        // We assert the final emitted state has success status and correct data.
        isA<MyOrdersState>()
            .having((s) => s.paginationState.resource.status, 'status', ApiStatus.success)
            .having((s) => s.paginationState.resource.data, 'data', mockOrders),
      ],
      verify: (_) {
        verify(mockGetOrdersUseCase.call(pageNumber: 1, pageSize: 10)).called(1);
      },
    );

    blocTest<MyOrdersCubit, MyOrdersState>(
      'emits error state when MyOrdersStarted is added and use case fails',
      build: () {
        when(mockGetOrdersUseCase.call(pageNumber: anyNamed('pageNumber'), pageSize: anyNamed('pageSize'))).thenAnswer((_) async => ErrorResponse(error: 'Failed'));
        return cubit;
      },
      act: (cubit) => cubit.doEvents(MyOrdersStarted()),
      expect: () => [
        isA<MyOrdersState>()
            .having((s) => s.paginationState.resource.status, 'status', ApiStatus.error),
      ],
    );
  });
}
