import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/core/pagination/pagination_model.dart';
import 'package:flower_app/features/commerce/domain/entities/category_entity.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_categories_use_case.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_products_use_case.dart';
import 'package:flower_app/features/commerce/presentation/categories/manager/categories_cubit.dart';
import 'package:flower_app/features/commerce/presentation/categories/manager/categories_events.dart';
import 'package:flower_app/features/commerce/presentation/categories/manager/categories_state.dart';
import 'package:flower_app/features/commerce/presentation/categories/manager/sort_option.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'categories_cubit_test.mocks.dart';

@GenerateMocks([GetCategoriesUseCase, GetProductsUseCase])
void main() {
  late MockGetCategoriesUseCase mockGetCategoriesUseCase;
  late MockGetProductsUseCase mockGetProductsUseCase;
  late CategoriesCubit cubit;

  const roses = CategoryEntity(id: 'c1', name: 'Roses', icon: 'roses.png');
  const tulips = CategoryEntity(id: 'c2', name: 'Tulips', icon: 'tulips.png');
  const categories = <CategoryEntity>[roses, tulips];

  const rosesProducts = <ProductEntity>[
    ProductEntity(id: 'p1', name: 'Red Rose Bouquet', price: 250),
  ];
  const tulipsProducts = <ProductEntity>[
    ProductEntity(id: 'p2', name: 'White Tulip Box', price: 400),
  ];

  final rosesPaginated = PaginatedResponse<ProductEntity>(
    data: rosesProducts,
    pagination: PaginationModel(page: 1, pageSize: 10, totalCount: 1, totalPages: 1, hasNextPage: false, hasPreviousPage: false),
  );
  
  final tulipsPaginated = PaginatedResponse<ProductEntity>(
    data: tulipsProducts,
    pagination: PaginationModel(page: 1, pageSize: 10, totalCount: 1, totalPages: 1, hasNextPage: false, hasPreviousPage: false),
  );

  setUpAll(() {
    provideDummy<BaseResponse<List<CategoryEntity>>>(
      const SuccessResponse(<CategoryEntity>[]),
    );
    provideDummy<BaseResponse<PaginatedResponse<ProductEntity>>>(
      SuccessResponse(rosesPaginated),
    );
  });

  setUp(() {
    mockGetCategoriesUseCase = MockGetCategoriesUseCase();
    mockGetProductsUseCase = MockGetProductsUseCase();
    cubit = CategoriesCubit(
      mockGetCategoriesUseCase,
      mockGetProductsUseCase,
    );
  });

  tearDown(() => cubit.close());

  void stubCategories(BaseResponse<List<CategoryEntity>> response) {
    when(mockGetCategoriesUseCase()).thenAnswer((_) async => response);
  }

  void stubProducts(
    String categoryId,
    BaseResponse<PaginatedResponse<ProductEntity>> response,
  ) {
    when(
      mockGetProductsUseCase(
        categoryId: categoryId,
        keyword: anyNamed('keyword'),
        sortBy: anyNamed('sortBy'),
        pageNumber: anyNamed('pageNumber'),
        pageSize: anyNamed('pageSize'),
      ),
    ).thenAnswer((_) async => response);
  }

  group('CategoriesStarted Test', () {
    test('loads the categories and opens on the first one by default', () async {
      stubCategories(const SuccessResponse(categories));
      stubProducts('c1', SuccessResponse(rosesPaginated));

      await cubit.doEvents(CategoriesStarted());

      expect(cubit.state.categoriesResource.isSuccess, true);
      expect(cubit.state.categoriesResource.data, categories);
      expect(cubit.state.selectedCategoryId, 'c1');
      expect(cubit.state.productsPagination.resource.isSuccess, true);
      expect(cubit.state.productsPagination.resource.data, rosesProducts);

      verify(mockGetCategoriesUseCase()).called(1);
      verify(mockGetProductsUseCase(
        categoryId: 'c1',
        keyword: null,
        sortBy: null,
        pageNumber: 1,
        pageSize: 10,
      )).called(1);
    });

    test('opens on the category tapped on Home when it is one of the tabs', () async {
      stubCategories(const SuccessResponse(categories));
      stubProducts('c2', SuccessResponse(tulipsPaginated));

      await cubit.doEvents(CategoriesStarted(initialCategoryId: 'c2'));

      expect(cubit.state.selectedCategoryId, 'c2');
      expect(cubit.state.productsPagination.resource.data, tulipsProducts);
    });

    test('never asks for products when the category list comes back empty', () async {
      stubCategories(const SuccessResponse(<CategoryEntity>[]));

      await cubit.doEvents(CategoriesStarted());

      expect(cubit.state.categoriesResource.isSuccess, true);
      expect(cubit.state.selectedCategoryId, isNull);
      expect(cubit.state.productsPagination.resource.status, ApiStatus.initial);

      verifyNever(mockGetProductsUseCase(
        categoryId: anyNamed('categoryId'),
        keyword: anyNamed('keyword'),
        sortBy: anyNamed('sortBy'),
        pageNumber: anyNamed('pageNumber'),
        pageSize: anyNamed('pageSize'),
      ));
    });
  });

  group('CategorySelected Test', () {
    test('emits loading then the products of the tapped category', () async {
      stubProducts('c2', SuccessResponse(tulipsPaginated));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<CategoriesState>()
              .having((s) => s.selectedCategoryId, 'selectedCategoryId', 'c2')
              .having((s) => s.productsPagination.resource.isLoading, 'loading', true),
          isA<CategoriesState>()
              .having((s) => s.productsPagination.resource.isSuccess, 'success', true)
              .having((s) => s.productsPagination.resource.data, 'data', tulipsProducts),
        ]),
      );
      
      final selecting = cubit.doEvents(CategorySelected('c2'));
      await expectation;
      await selecting;
    });
  });

  group('Debounce and Sort Test', () {
    test('Search keyword sets keyword and calls use case after debounce', () async {
      stubProducts('c1', SuccessResponse(rosesPaginated));
      await cubit.doEvents(CategorySelected('c1'));

      cubit.doEvents(CategoriesSearchChanged('red'));
      
      expect(cubit.state.keyword, 'red');
      
      await Future.delayed(const Duration(milliseconds: 600));
      expect(cubit.state.productsPagination.resource.isSuccess, true);
      
      verify(mockGetProductsUseCase(
        categoryId: 'c1',
        keyword: 'red',
        sortBy: null,
        pageNumber: 1,
        pageSize: 10,
      )).called(1);
    });

    test('Sort selection updates sortOption and calls use case', () async {
      stubProducts('c1', SuccessResponse(rosesPaginated));
      await cubit.doEvents(CategorySelected('c1'));

      await cubit.doEvents(CategoriesSortChanged(SortOption.priceLowToHigh));
      
      expect(cubit.state.sortOption, SortOption.priceLowToHigh);
      
      verify(mockGetProductsUseCase(
        categoryId: 'c1',
        keyword: null,
        sortBy: 'PriceLowToHigh',
        pageNumber: 1,
        pageSize: 10,
      )).called(1);
    });
  });
}

