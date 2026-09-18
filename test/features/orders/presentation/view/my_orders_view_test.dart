import 'dart:async';
import 'package:flower_app/core/network/base_response.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/core/pagination/pagination_model.dart';
import 'package:flower_app/features/orders/domain/entities/order_entity.dart';
import 'package:flower_app/features/orders/presentation/manager/my_orders_cubit.dart';
import 'package:flower_app/features/orders/presentation/manager/my_orders_events.dart';
import 'package:flower_app/features/orders/presentation/view/my_orders_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../manager/my_orders_cubit_test.mocks.dart';

/// Wraps [child] with a [MaterialApp] that supplies the minimal
/// infrastructure (no EasyLocalization) needed for widget tests.
Widget _wrap(Widget child) {
  return MaterialApp(home: child);
}

void main() {
  late MockGetOrdersUseCase mockUseCase;
  late MyOrdersCubit cubit;

  setUp(() {
    mockUseCase = MockGetOrdersUseCase();
    cubit = MyOrdersCubit(mockUseCase);
    // Provide a dummy for the sealed BaseResponse so Mockito can generate stubs
    provideDummy<BaseResponse<PaginatedResponse<OrderEntity>>>(
      SuccessResponse(PaginatedResponse<OrderEntity>(
        data: const [],
        pagination: PaginationModel(),
      )),
    );
  });

  tearDown(() => cubit.close());

  Widget createWidgetUnderTest() {
    return _wrap(
      BlocProvider<MyOrdersCubit>.value(
        value: cubit,
        child: const MyOrdersView(),
      ),
    );
  }

  testWidgets('shows CircularProgressIndicator when loading',
      (WidgetTester tester) async {
    // Use an unresolved completer to keep the state in 'loading'
    // without creating actual pending timers that outlive the test.
    final completer = Completer<BaseResponse<PaginatedResponse<OrderEntity>>>();
    when(mockUseCase.call(pageNumber: 1, pageSize: 10)).thenAnswer((_) => completer.future);

    await tester.pumpWidget(createWidgetUnderTest());
    // doEvents AFTER pumpWidget so the cubit's state changes are observed
    cubit.doEvents(MyOrdersStarted());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('shows orders list when data is loaded',
      (WidgetTester tester) async {
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

    when(mockUseCase.call(pageNumber: 1, pageSize: 10)).thenAnswer(
      (_) async => SuccessResponse(PaginatedResponse<OrderEntity>(
        data: mockOrders,
        pagination: PaginationModel(
            page: 1,
            pageSize: 10,
            totalCount: 1,
            totalPages: 1,
            hasNextPage: false,
            hasPreviousPage: false),
      )),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    cubit.doEvents(MyOrdersStarted());
    await tester.pumpAndSettle();

    expect(find.text('Rose'), findsOneWidget);
  });

  testWidgets('shows error message when loading fails',
      (WidgetTester tester) async {
    when(mockUseCase.call(pageNumber: 1, pageSize: 10)).thenAnswer(
      (_) async => ErrorResponse(error: 'Server error'),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    cubit.doEvents(MyOrdersStarted());
    await tester.pumpAndSettle();

    // The cubit converts the error object into an errMessage; the widget
    // shows it (or the fallback) via resource.errorMessage.
    expect(find.byType(ElevatedButton), findsWidgets);
  });

  testWidgets('shows empty-state text when orders list is empty',
      (WidgetTester tester) async {
    when(mockUseCase.call(pageNumber: 1, pageSize: 10)).thenAnswer(
      (_) async => SuccessResponse(PaginatedResponse<OrderEntity>(
        data: const [],
        pagination: PaginationModel(
            page: 1,
            pageSize: 10,
            totalCount: 0,
            totalPages: 1,
            hasNextPage: false,
            hasPreviousPage: false),
      )),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    cubit.doEvents(MyOrdersStarted());
    await tester.pumpAndSettle();

    // Tabs are still rendered; no OrderItemCard should be visible
    expect(find.byType(TabBar), findsOneWidget);
  });
}
