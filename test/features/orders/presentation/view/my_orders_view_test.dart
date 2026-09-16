import 'package:flower_app/features/orders/domain/entities/order_entity.dart';
import 'package:flower_app/features/orders/presentation/manager/my_orders_cubit.dart';
import 'package:flower_app/features/orders/presentation/manager/my_orders_events.dart';
import 'package:flower_app/features/orders/presentation/view/my_orders_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../manager/my_orders_cubit_test.mocks.dart';

void main() {
  late MockGetOrdersUseCase mockUseCase;
  late MyOrdersCubit cubit;

  setUp(() {
    mockUseCase = MockGetOrdersUseCase();
    cubit = MyOrdersCubit(mockUseCase);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<MyOrdersCubit>.value(
        value: cubit,
        child: const MyOrdersView(),
      ),
    );
  }

  testWidgets('shows CircularProgressIndicator when loading', (WidgetTester tester) async {
    when(mockUseCase.call()).thenAnswer((_) async {
      await Future.delayed(const Duration(seconds: 1));
      return <OrderEntity>[];
    });

    cubit.doEvents(MyOrdersStarted());
    
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('shows orders list when data is loaded', (WidgetTester tester) async {
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

    when(mockUseCase.call()).thenAnswer((_) async => mockOrders);
    
    cubit.doEvents(MyOrdersStarted());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Rose'), findsOneWidget);
  });
}
