import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flower_app/features/commerce/domain/entities/product_details_entity.dart';
import 'package:flower_app/features/commerce/presentation/product_details/view/product_details_view.dart';
import 'package:flower_app/features/commerce/presentation/product_details/view_model/product_details_state.dart';
import 'package:flower_app/features/commerce/presentation/product_details/view_model/product_details_view_model.dart';
import 'package:flower_app/features/commerce/presentation/product_details/view_model/product_details_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockProductDetailsViewModel extends Mock implements ProductDetailsViewModel {
  @override
  ProductDetailsState get state => super.noSuchMethod(
        Invocation.getter(#state),
        returnValue: ProductDetailsState(resource: Resource.initial()),
        returnValueForMissingStub: ProductDetailsState(resource: Resource.initial()),
      );

  @override
  Stream<ProductDetailsState> get stream => super.noSuchMethod(
        Invocation.getter(#stream),
        returnValue: const Stream<ProductDetailsState>.empty(),
        returnValueForMissingStub: const Stream<ProductDetailsState>.empty(),
      );

  @override
  void doEvent(ProductDetailsEvent event) => super.noSuchMethod(
        Invocation.method(#doEvent, [event]),
        returnValueForMissingStub: null,
      );

  @override
  Future<void> close() => super.noSuchMethod(
        Invocation.method(#close, []),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );
}

void main() {
  late MockProductDetailsViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockProductDetailsViewModel();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<ProductDetailsViewModel>(
        create: (_) => mockViewModel,
        child: const ProductDetailsView(
          product: ProductEntity(id: '1', name: 'Test Product'),
        ),
      ),
    );
  }

  testWidgets('shows loading indicator when loading', (tester) async {
    final loadingState = ProductDetailsState(resource: Resource.loading());
    when(mockViewModel.state).thenReturn(loadingState);
    when(mockViewModel.stream).thenAnswer((_) => Stream.value(loadingState));

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows product details when loaded', (tester) async {
    final loadedState = ProductDetailsState(
      resource: Resource.success(
        ProductDetailsEntity(
          id: '1',
          name: 'Awesome Product',
          price: 99.99,
          currency: 'EGP',
          description: 'This is an awesome product.',
        ),
      ),
    );
    when(mockViewModel.state).thenReturn(loadedState);
    when(mockViewModel.stream).thenAnswer((_) => Stream.value(loadedState));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Awesome Product'), findsOneWidget);
    expect(find.text('This is an awesome product.'), findsOneWidget);
    expect(find.textContaining('99.99'), findsOneWidget);
  });
}
