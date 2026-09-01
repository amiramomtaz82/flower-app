import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/core/pagination/pagination_model.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_products_use_case.dart';
import 'package:flower_app/features/commerce/presentation/search/manager/search_cubit.dart';
import 'package:flower_app/features/commerce/presentation/search/manager/search_events.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flower_app/config/base_response/base_response.dart';

import 'search_cubit_test.mocks.dart';

@GenerateMocks([GetProductsUseCase])
void main() {
  late MockGetProductsUseCase mockGetProductsUseCase;
  late SearchCubit cubit;

  const product = ProductEntity(id: 'p1', name: 'Test Product', price: 100);
  const products = [product];
  final paginatedResponse = PaginatedResponse<ProductEntity>(
    data: products,
    pagination: PaginationModel(
      page: 1,
      pageSize: 10,
      totalCount: 1,
      totalPages: 1,
      hasNextPage: false,
      hasPreviousPage: false,
    ),
  );

  setUpAll(() {
    provideDummy<BaseResponse<PaginatedResponse<ProductEntity>>>(
      SuccessResponse(paginatedResponse),
    );
  });

  setUp(() {
    mockGetProductsUseCase = MockGetProductsUseCase();
    cubit = SearchCubit(mockGetProductsUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  void stubProducts(BaseResponse<PaginatedResponse<ProductEntity>> response) {
    when(mockGetProductsUseCase(
      keyword: anyNamed('keyword'),
      pageNumber: anyNamed('pageNumber'),
      pageSize: anyNamed('pageSize'),
    )).thenAnswer((_) async => response);
  }

  group('SearchCubit', () {
    test('initial state has empty keyword and initial pagination state', () {
      expect(cubit.state.keyword, isEmpty);
      expect(cubit.state.productsPagination.resource.status, ApiStatus.initial);
    });

    test('SearchQueryChanged updates keyword and fetches products if not empty', () async {
      stubProducts(SuccessResponse(paginatedResponse));

      cubit.doEvents(SearchQueryChanged('rose'));

      expect(cubit.state.keyword, 'rose');

      await Future.delayed(const Duration(milliseconds: 600));

      expect(cubit.state.productsPagination.resource.isSuccess, true);
      verify(mockGetProductsUseCase(
        keyword: 'rose',
        pageNumber: 1,
        pageSize: 10,
      )).called(1);
    });

    test('SearchQueryChanged clears products when keyword is empty', () async {
      cubit.doEvents(SearchQueryChanged('  ')); 

      await Future.delayed(const Duration(milliseconds: 100));

      expect(cubit.state.keyword, '  ');
      expect(cubit.state.productsPagination.resource.status, ApiStatus.initial);
      verifyNever(mockGetProductsUseCase(
        keyword: anyNamed('keyword'),
        pageNumber: anyNamed('pageNumber'),
        pageSize: anyNamed('pageSize'),
      ));
    });
  });
}

