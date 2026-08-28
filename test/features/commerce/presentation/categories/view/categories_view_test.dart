import 'dart:async';

import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/commerce/domain/entities/category_entity.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_categories_use_case.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_products_by_category_use_case.dart';
import 'package:flower_app/features/commerce/presentation/categories/manager/categories_cubit.dart';
import 'package:flower_app/features/commerce/presentation/categories/manager/categories_events.dart';
import 'package:flower_app/features/commerce/presentation/categories/view/categories_view.dart';
import 'package:flower_app/features/commerce/presentation/widgets/custom_product_card.dart';
import 'package:flower_app/features/commerce/presentation/widgets/selection_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'categories_view_test.mocks.dart';

// The view is driven through a real cubit with mocked use cases, so the test
// covers the wiring between the two rather than a stubbed-out state.
@GenerateMocks([GetCategoriesUseCase, GetProductsByCategoryUseCase])
void main() {
  late MockGetCategoriesUseCase mockGetCategoriesUseCase;
  late MockGetProductsByCategoryUseCase mockGetProductsByCategoryUseCase;
  late CategoriesCubit cubit;

  const roses = CategoryEntity(id: 'c1', name: 'Roses', icon: 'roses.png');
  const tulips = CategoryEntity(id: 'c2', name: 'Tulips', icon: 'tulips.png');
  const categories = <CategoryEntity>[roses, tulips];

  const rosesProducts = <ProductEntity>[
    ProductEntity(id: 'p1', name: 'Red Rose Bouquet', price: 250, currency: 'EGP'),
  ];
  const tulipsProducts = <ProductEntity>[
    ProductEntity(id: 'p2', name: 'White Tulip Box', price: 400, currency: 'EGP'),
  ];

  // mockito cannot build a value of a sealed type on its own
  setUpAll(() {
    provideDummy<BaseResponse<List<CategoryEntity>>>(
      const SuccessResponse(<CategoryEntity>[]),
    );
    provideDummy<BaseResponse<List<ProductEntity>>>(
      const SuccessResponse(<ProductEntity>[]),
    );
  });

  // setup before each test, so mocks/stubs never leak between tests
  setUp(() {
    mockGetCategoriesUseCase = MockGetCategoriesUseCase();
    mockGetProductsByCategoryUseCase = MockGetProductsByCategoryUseCase();
    cubit = CategoriesCubit(
      mockGetCategoriesUseCase,
      mockGetProductsByCategoryUseCase,
    );
  });

  tearDown(() => cubit.close());

  void stubCategories(BaseResponse<List<CategoryEntity>> response) {
    when(mockGetCategoriesUseCase()).thenAnswer((_) async => response);
  }

  void stubProducts(
    String categoryId,
    BaseResponse<List<ProductEntity>> response,
  ) {
    when(
      mockGetProductsByCategoryUseCase(categoryId: categoryId),
    ).thenAnswer((_) async => response);
  }

  Future<void> pumpView(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<CategoriesCubit>.value(
          value: cubit,
          child: const CategoriesView(),
        ),
      ),
    );
  }

  // the three states the page can be in before any tab is drawn
  group('Categories List States Test', () {
    testWidgets('shows a spinner while the categories are loading', (
      tester,
    ) async {
      // Arrange: the request is left hanging so the loading state stays put
      final pending = Completer<BaseResponse<List<CategoryEntity>>>();
      when(mockGetCategoriesUseCase()).thenAnswer((_) => pending.future);

      // Act
      await pumpView(tester);
      unawaited(cubit.doEvents(CategoriesStarted()));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(SelectionTabs), findsNothing);
    });

    testWidgets('shows the error message when the categories fail', (
      tester,
    ) async {
      // Arrange
      stubCategories(
        ErrorResponse<List<CategoryEntity>>(errMessage: 'No internet connection'),
      );

      // Act
      await cubit.doEvents(CategoriesStarted());
      await pumpView(tester);

      // Assert
      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.byType(SelectionTabs), findsNothing);
    });

    testWidgets('shows an empty message when there are no categories', (
      tester,
    ) async {
      // Arrange
      stubCategories(const SuccessResponse(<CategoryEntity>[]));

      // Act
      await cubit.doEvents(CategoriesStarted());
      await pumpView(tester);

      // Assert
      expect(find.text('No categories yet'), findsOneWidget);
      expect(find.byType(SelectionTabs), findsNothing);
    });
  });

  // the loaded page: tabs on top, the selected category's products below
  group('Categories Content Test', () {
    testWidgets('renders a tab per category and the products of the selected one', (
      tester,
    ) async {
      // Arrange
      stubCategories(const SuccessResponse(categories));
      stubProducts('c1', const SuccessResponse(rosesProducts));

      // Act
      await cubit.doEvents(CategoriesStarted());
      await pumpView(tester);

      // Assert
      expect(find.byType(SelectionTabs), findsOneWidget);
      expect(find.text('Roses'), findsOneWidget);
      expect(find.text('Tulips'), findsOneWidget);
      expect(find.byType(CustomProductCard), findsOneWidget);
      expect(find.text('Red Rose Bouquet'), findsOneWidget);
    });

    testWidgets('shows an empty message when the category has no products', (
      tester,
    ) async {
      // Arrange
      stubCategories(const SuccessResponse(categories));
      stubProducts('c1', const SuccessResponse(<ProductEntity>[]));

      // Act
      await cubit.doEvents(CategoriesStarted());
      await pumpView(tester);

      // Assert
      expect(find.text('No products in this category yet'), findsOneWidget);
      expect(find.byType(CustomProductCard), findsNothing);
      // the tabs stay put, so the user can pick another category
      expect(find.byType(SelectionTabs), findsOneWidget);
    });

    testWidgets('shows the error message when the products fail', (
      tester,
    ) async {
      // Arrange
      stubCategories(const SuccessResponse(categories));
      stubProducts(
        'c1',
        ErrorResponse<List<ProductEntity>>(errMessage: 'Server error'),
      );

      // Act
      await cubit.doEvents(CategoriesStarted());
      await pumpView(tester);

      // Assert
      expect(find.text('Server error'), findsOneWidget);
      expect(find.byType(SelectionTabs), findsOneWidget);
    });
  });

  // tapping a tab has to reach the cubit and swap the grid
  group('Tab Tap Test', () {
    testWidgets('tapping a tab loads and shows that category products', (
      tester,
    ) async {
      // Arrange
      stubCategories(const SuccessResponse(categories));
      stubProducts('c1', const SuccessResponse(rosesProducts));
      stubProducts('c2', const SuccessResponse(tulipsProducts));
      await cubit.doEvents(CategoriesStarted());
      await pumpView(tester);

      // Act
      await tester.tap(find.text('Tulips'));
      await tester.pump(); // dispatch the tap
      await tester.pump(); // rebuild once the products come back

      // Assert
      expect(cubit.state.selectedCategoryId, 'c2');
      expect(find.text('White Tulip Box'), findsOneWidget);
      expect(find.text('Red Rose Bouquet'), findsNothing);

      verify(mockGetProductsByCategoryUseCase(categoryId: 'c2')).called(1);
    });
  });
}
