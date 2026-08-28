import 'package:dio/dio.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/features/commerce/data/data_sorce/remote/commerce_remote_data_source.dart';
import 'package:flower_app/features/commerce/data/models/category_dto.dart';
import 'package:flower_app/features/commerce/data/models/home_section_dto.dart';
import 'package:flower_app/features/commerce/data/models/occasion_dto.dart';
import 'package:flower_app/features/commerce/data/models/occasions_data_model.dart';
import 'package:flower_app/features/commerce/data/models/product_dto.dart';
import 'package:flower_app/features/commerce/data/models/products_data_model.dart';
import 'package:flower_app/features/commerce/data/repo_impl/commerce_repo_impl.dart';
import 'package:flower_app/features/commerce/domain/entities/category_entity.dart';
import 'package:flower_app/features/commerce/domain/entities/home_section_entity.dart';
import 'package:flower_app/features/commerce/domain/entities/home_section_type.dart';
import 'package:flower_app/features/commerce/domain/entities/occasion_entity.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'commerce_repo_impl_test.mocks.dart';

@GenerateMocks([CommerceRemoteDataSource])
void main() {
  late MockCommerceRemoteDataSource mockRemoteDataSource;
  late CommerceRepoImpl repo;

  final dioException = DioException(requestOptions: RequestOptions(path: ''));

  setUp(() {
    mockRemoteDataSource = MockCommerceRemoteDataSource();
    repo = CommerceRepoImpl(mockRemoteDataSource);
  });

  group('getHomeSections', () {
    test('returns SuccessResponse with mapped entities on success', () async {
      when(mockRemoteDataSource.getHomeSections()).thenAnswer(
        (_) async => const [
          HomeSectionDTO(
            id: 'section-1',
            type: HomeSectionTypeDto.categories,
            index: 0,
            isActive: true,
            title: 'Categories',
          ),
        ],
      );

      final result = await repo.getHomeSections();

      expect(result, isA<SuccessResponse<List<HomeSectionEntity>>>());
      expect((result as SuccessResponse<List<HomeSectionEntity>>).data, [
        const HomeSectionEntity(
          id: 'section-1',
          type: HomeSectionType.categories,
          index: 0,
          isActive: true,
          title: 'Categories',
        ),
      ]);
    });

    test('returns ErrorResponse when the remote call throws', () async {
      when(
        mockRemoteDataSource.getHomeSections(),
      ).thenThrow(dioException);

      final result = await repo.getHomeSections();

      expect(result, isA<ErrorResponse<List<HomeSectionEntity>>>());
    });
  });

  group('getCategories', () {
    test('returns SuccessResponse with mapped entities on success', () async {
      when(mockRemoteDataSource.getCategories()).thenAnswer(
        (_) async => const [
          CategoryDTO(id: '1', name: 'Roses', icon: 'roses.png'),
        ],
      );

      final result = await repo.getCategories();

      expect(result, isA<SuccessResponse<List<CategoryEntity>>>());
      expect((result as SuccessResponse<List<CategoryEntity>>).data, [
        const CategoryEntity(id: '1', name: 'Roses', icon: 'roses.png'),
      ]);
    });

    test('returns ErrorResponse when the remote call throws', () async {
      when(mockRemoteDataSource.getCategories()).thenThrow(dioException);

      final result = await repo.getCategories();

      expect(result, isA<ErrorResponse<List<CategoryEntity>>>());
    });
  });

  group('getOccasions', () {
    test(
      'returns SuccessResponse with a mapped PaginatedResponse on success',
      () async {
        when(
          mockRemoteDataSource.getOccasions(pageNumber: 1, pageSize: 10),
        ).thenAnswer(
          (_) async => const OccasionsDataModel(
            items: [
              OccasionDTO(id: '1', name: 'Birthday', imageUrl: 'b.png'),
            ],
            totalCount: 1,
            pageNumber: 1,
            pageSize: 10,
            totalPages: 1,
            hasNextPage: false,
            hasPreviousPage: false,
          ),
        );

        final result = await repo.getOccasions(pageNumber: 1, pageSize: 10);

        expect(
          result,
          isA<SuccessResponse<PaginatedResponse<OccasionEntity>>>(),
        );
        final data =
            (result as SuccessResponse<PaginatedResponse<OccasionEntity>>)
                .data;
        expect(data.data, [
          const OccasionEntity(id: '1', name: 'Birthday', imageUrl: 'b.png'),
        ]);
        expect(data.pagination.totalCount, 1);
        expect(data.pagination.page, 1);
      },
    );

    test('returns ErrorResponse when the remote call throws', () async {
      when(
        mockRemoteDataSource.getOccasions(pageNumber: 1, pageSize: 10),
      ).thenThrow(dioException);

      final result = await repo.getOccasions(pageNumber: 1, pageSize: 10);

      expect(
        result,
        isA<ErrorResponse<PaginatedResponse<OccasionEntity>>>(),
      );
    });
  });

  group('getProducts', () {
    test(
      'returns SuccessResponse with a mapped PaginatedResponse on success',
      () async {
        when(
          mockRemoteDataSource.getProducts(
            occasionId: 'occ-1',
            pageNumber: 1,
            pageSize: 10,
          ),
        ).thenAnswer(
          (_) async => const ProductsDataModel(
            items: [ProductDTO(id: 'p1', name: 'Rose Bouquet', price: 100)],
            totalCount: 1,
            pageNumber: 1,
            pageSize: 10,
            totalPages: 1,
            hasNextPage: false,
            hasPreviousPage: false,
          ),
        );

        final result = await repo.getProducts(
          occasionId: 'occ-1',
          pageNumber: 1,
          pageSize: 10,
        );

        expect(
          result,
          isA<SuccessResponse<PaginatedResponse<ProductEntity>>>(),
        );
        final data =
            (result as SuccessResponse<PaginatedResponse<ProductEntity>>)
                .data;
        expect(data.data.single.id, 'p1');
        expect(data.data.single.name, 'Rose Bouquet');
      },
    );

    test('returns ErrorResponse when the remote call throws', () async {
      when(
        mockRemoteDataSource.getProducts(
          occasionId: 'occ-1',
          pageNumber: 1,
          pageSize: 10,
        ),
      ).thenThrow(dioException);

      final result = await repo.getProducts(
        occasionId: 'occ-1',
        pageNumber: 1,
        pageSize: 10,
      );

      expect(result, isA<ErrorResponse<PaginatedResponse<ProductEntity>>>());
    });
  });

  group('getProductsByCategory', () {
    test('returns SuccessResponse with mapped entities on success', () async {
      when(
        mockRemoteDataSource.getProductsByCategory(categoryId: 'cat-1'),
      ).thenAnswer(
        (_) async => const [ProductDTO(id: 'p1', name: 'Tulip Bunch')],
      );

      final result = await repo.getProductsByCategory(categoryId: 'cat-1');

      expect(result, isA<SuccessResponse<List<ProductEntity>>>());
      expect(
        (result as SuccessResponse<List<ProductEntity>>).data.single.id,
        'p1',
      );
    });

    test('returns ErrorResponse when the remote call throws', () async {
      when(
        mockRemoteDataSource.getProductsByCategory(categoryId: 'cat-1'),
      ).thenThrow(dioException);

      final result = await repo.getProductsByCategory(categoryId: 'cat-1');

      expect(result, isA<ErrorResponse<List<ProductEntity>>>());
    });
  });

  group('getProductById', () {
    test('returns SuccessResponse with the mapped entity on success', () async {
      when(mockRemoteDataSource.getProductById(productId: 'p1')).thenAnswer(
        (_) async => const ProductDTO(id: 'p1', name: 'Rose Bouquet'),
      );

      final result = await repo.getProductById(productId: 'p1');

      expect(result, isA<SuccessResponse<ProductEntity>>());
      expect((result as SuccessResponse<ProductEntity>).data.id, 'p1');
    });

    test('returns ErrorResponse when the remote call throws', () async {
      when(
        mockRemoteDataSource.getProductById(productId: 'p1'),
      ).thenThrow(dioException);

      final result = await repo.getProductById(productId: 'p1');

      expect(result, isA<ErrorResponse<ProductEntity>>());
    });
  });
}
