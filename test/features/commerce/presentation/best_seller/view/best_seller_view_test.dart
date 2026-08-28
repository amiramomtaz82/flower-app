import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/pagination/pagination_state.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flower_app/features/commerce/presentation/best_seller/view/best_seller_view.dart';
import 'package:flower_app/features/commerce/presentation/best_seller/view_model/best_seller_view_model.dart';
import 'package:flower_app/features/commerce/presentation/best_seller/view_model/best_seller_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockBestSellerViewModel extends Mock implements BestSellerViewModel {
  @override
  PaginationState<ProductEntity> get state => super.noSuchMethod(
        Invocation.getter(#state),
        returnValue: PaginationState<ProductEntity>.initial(),
        returnValueForMissingStub: PaginationState<ProductEntity>.initial(),
      );

  @override
  Stream<PaginationState<ProductEntity>> get stream => super.noSuchMethod(
        Invocation.getter(#stream),
        returnValue: const Stream<PaginationState<ProductEntity>>.empty(),
        returnValueForMissingStub: const Stream<PaginationState<ProductEntity>>.empty(),
      );

  @override
  Future<void> doEvent(BestSellerEvent event) => super.noSuchMethod(
        Invocation.method(#doEvent, [event]),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );

  @override
  Future<void> close() => super.noSuchMethod(
        Invocation.method(#close, []),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );
}

void main() {
  late MockBestSellerViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockBestSellerViewModel();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<BestSellerViewModel>(
        create: (_) => mockViewModel,
        child: const BestSellerView(),
      ),
    );
  }

  testWidgets('shows loading indicator when loading', (tester) async {
    when(mockViewModel.state).thenReturn(
      PaginationState<ProductEntity>.initial().copyWith(resource: Resource.loading()),
    );
    when(mockViewModel.stream).thenAnswer((_) => Stream.value(
          PaginationState<ProductEntity>.initial().copyWith(resource: Resource.loading()),
        ));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows products when loaded', (tester) async {
    final products = [
      ProductEntity(id: '1', name: 'Product 1', price: 100),
      ProductEntity(id: '2', name: 'Product 2', price: 200),
    ];
    final loadedState = PaginationState<ProductEntity>.initial().copyWith(
      resource: Resource.success(products),
    );
    when(mockViewModel.state).thenReturn(loadedState);
    when(mockViewModel.stream).thenAnswer((_) => Stream.value(loadedState));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Product 1'), findsOneWidget);
    expect(find.text('Product 2'), findsOneWidget);
  });
}
