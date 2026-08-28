import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/core/pagination/pagination_model.dart';
import 'package:flower_app/features/commerce/domain/entities/category_entity.dart';
import 'package:flower_app/features/commerce/domain/entities/home_section_entity.dart';
import 'package:flower_app/features/commerce/domain/entities/home_section_type.dart';
import 'package:flower_app/features/commerce/domain/entities/occasion_entity.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_categories_use_case.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_home_sections_use_case.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_occasions_use_case.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_products_by_category_use_case.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_products_use_case.dart';
import 'package:flower_app/features/commerce/presentation/home/manager/home_cubit.dart';
import 'package:flower_app/features/commerce/presentation/home/manager/home_events.dart';
import 'package:flower_app/features/commerce/presentation/home/manager/home_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_cubit_test.mocks.dart';

@GenerateMocks([
  GetHomeSectionsUseCase,
  GetCategoriesUseCase,
  GetOccasionsUseCase,
  GetProductsUseCase,
  GetProductsByCategoryUseCase,
])
void main() {
  late MockGetHomeSectionsUseCase mockGetHomeSectionsUseCase;
  late MockGetCategoriesUseCase mockGetCategoriesUseCase;
  late MockGetOccasionsUseCase mockGetOccasionsUseCase;
  late MockGetProductsUseCase mockGetProductsUseCase;
  late MockGetProductsByCategoryUseCase mockGetProductsByCategoryUseCase;
  late HomeCubit cubit;

  const categoriesSection = HomeSectionEntity(
    id: 'section-categories',
    type: HomeSectionType.categories,
    index: 0,
    isActive: true,
  );
  const occasionsSection = HomeSectionEntity(
    id: 'section-occasions',
    type: HomeSectionType.occasions,
    index: 1,
    isActive: true,
  );
  const bestSellerSection = HomeSectionEntity(
    id: 'section-best-seller',
    type: HomeSectionType.bestSeller,
    index: 2,
    isActive: true,
  );
  const carouselByOccasionSection = HomeSectionEntity(
    id: 'section-carousel-occasion',
    type: HomeSectionType.productsCarousel,
    index: 3,
    isActive: true,
    occasionId: 'occ-1',
  );
  const carouselByCategorySection = HomeSectionEntity(
    id: 'section-carousel-category',
    type: HomeSectionType.productsCarousel,
    index: 4,
    isActive: true,
    categoryId: 'cat-1',
  );
  const carouselWithNoFilterSection = HomeSectionEntity(
    id: 'section-carousel-no-filter',
    type: HomeSectionType.productsCarousel,
    index: 5,
    isActive: true,
  );
  final occasion = const OccasionEntity(
    id: 'occ-1',
    name: 'Birthday',
    imageUrl: 'b.png',
  );

  PaginatedResponse<T> paginatedOf<T>(List<T> data) => PaginatedResponse(
    data: data,
    pagination: PaginationModel(
      page: 1,
      pageSize: 20,
      totalCount: data.length,
      totalPages: 1,
      hasNextPage: false,
      hasPreviousPage: false,
    ),
  );

  setUpAll(() {
    provideDummy<BaseResponse<List<HomeSectionEntity>>>(
      const SuccessResponse(<HomeSectionEntity>[]),
    );
    provideDummy<BaseResponse<List<CategoryEntity>>>(
      const SuccessResponse(<CategoryEntity>[]),
    );
    provideDummy<BaseResponse<PaginatedResponse<OccasionEntity>>>(
      SuccessResponse(paginatedOf(const <OccasionEntity>[])),
    );
    provideDummy<BaseResponse<PaginatedResponse<ProductEntity>>>(
      SuccessResponse(paginatedOf(const <ProductEntity>[])),
    );
    provideDummy<BaseResponse<List<ProductEntity>>>(
      const SuccessResponse(<ProductEntity>[]),
    );
  });

  setUp(() {
    mockGetHomeSectionsUseCase = MockGetHomeSectionsUseCase();
    mockGetCategoriesUseCase = MockGetCategoriesUseCase();
    mockGetOccasionsUseCase = MockGetOccasionsUseCase();
    mockGetProductsUseCase = MockGetProductsUseCase();
    mockGetProductsByCategoryUseCase = MockGetProductsByCategoryUseCase();

    cubit = HomeCubit(
      mockGetHomeSectionsUseCase,
      mockGetCategoriesUseCase,
      mockGetOccasionsUseCase,
      mockGetProductsUseCase,
      mockGetProductsByCategoryUseCase,
    );

    // Every case below drives at least one section through _loadSectionContent,
    // which always calls out to occasions/products — stub them with harmless
    // empty defaults so only the test that cares has to override them.
    when(
      mockGetOccasionsUseCase(pageNumber: anyNamed('pageNumber'), pageSize: anyNamed('pageSize')),
    ).thenAnswer((_) async => SuccessResponse(paginatedOf(const <OccasionEntity>[])));
    when(
      mockGetProductsUseCase(
        occasionId: anyNamed('occasionId'),
        pageNumber: anyNamed('pageNumber'),
        pageSize: anyNamed('pageSize'),
      ),
    ).thenAnswer((_) async => SuccessResponse(paginatedOf(const <ProductEntity>[])));
  });

  tearDown(() {
    cubit.close();
  });

  group('HomeStarted', () {
    test(
      'emits whatever sections the use case returns and loads each one',
      () async {
        when(mockGetHomeSectionsUseCase()).thenAnswer(
          (_) async => const SuccessResponse([
            categoriesSection,
            occasionsSection,
          ]),
        );
        when(mockGetCategoriesUseCase()).thenAnswer(
          (_) async => const SuccessResponse(<CategoryEntity>[]),
        );

        // Categories and occasions load concurrently here, so their
        // completion order isn't guaranteed — assert on the final state
        // instead of a strict emission order.
        await cubit.doEvents(HomeStarted());

        expect(cubit.state.sectionsResource.isSuccess, true);
        expect(cubit.state.sectionsResource.data, [
          categoriesSection,
          occasionsSection,
        ]);
        verify(mockGetCategoriesUseCase()).called(1);
      },
    );

    test('emits loading then an error when fetching sections fails', () async {
      when(mockGetHomeSectionsUseCase()).thenAnswer(
        (_) async => ErrorResponse(errMessage: 'network down'),
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HomeState>().having(
            (s) => s.sectionsResource.isLoading,
            'sectionsResource.isLoading',
            true,
          ),
          isA<HomeState>()
              .having(
                (s) => s.sectionsResource.isError,
                'sectionsResource.isError',
                true,
              )
              .having(
                (s) => s.sectionsResource.errorMessage,
                'sectionsResource.errorMessage',
                'network down',
              ),
        ]),
      );
      final acting = cubit.doEvents(HomeStarted());
      await expectation;
      await acting;
    });
  });

  group('Categories section', () {
    test('emits loading then the categories on success', () async {
      when(mockGetHomeSectionsUseCase()).thenAnswer(
        (_) async => const SuccessResponse([categoriesSection]),
      );
      const roses = CategoryEntity(id: '1', name: 'Roses', icon: 'roses.png');
      when(
        mockGetCategoriesUseCase(),
      ).thenAnswer((_) async => const SuccessResponse([roses]));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HomeState>().having(
            (s) => s.sectionsResource.isLoading,
            'sectionsResource.isLoading',
            true,
          ),
          isA<HomeState>().having(
            (s) => s.sectionsResource.isSuccess,
            'sectionsResource.isSuccess',
            true,
          ),
          isA<HomeState>().having(
            (s) => s.categoriesResource.isLoading,
            'categoriesResource.isLoading',
            true,
          ),
          isA<HomeState>()
              .having(
                (s) => s.categoriesResource.isSuccess,
                'categoriesResource.isSuccess',
                true,
              )
              .having(
                (s) => s.categoriesResource.data,
                'categoriesResource.data',
                [roses],
              ),
        ]),
      );
      final acting = cubit.doEvents(HomeStarted());
      await expectation;
      await acting;
    });
  });

  group('Occasions section', () {
    test('emits loading then the occasions on success', () async {
      when(mockGetHomeSectionsUseCase()).thenAnswer(
        (_) async => const SuccessResponse([occasionsSection]),
      );
      when(
        mockGetOccasionsUseCase(pageNumber: 1, pageSize: 20),
      ).thenAnswer((_) async => SuccessResponse(paginatedOf([occasion])));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HomeState>().having(
            (s) => s.sectionsResource.isLoading,
            'sectionsResource.isLoading',
            true,
          ),
          isA<HomeState>().having(
            (s) => s.sectionsResource.isSuccess,
            'sectionsResource.isSuccess',
            true,
          ),
          isA<HomeState>().having(
            (s) => s.occasionsResource.isLoading,
            'occasionsResource.isLoading',
            true,
          ),
          isA<HomeState>()
              .having(
                (s) => s.occasionsResource.isSuccess,
                'occasionsResource.isSuccess',
                true,
              )
              .having(
                (s) => s.occasionsResource.data,
                'occasionsResource.data',
                [occasion],
              ),
        ]),
      );
      final acting = cubit.doEvents(HomeStarted());
      await expectation;
      await acting;
    });
  });

  group('ProductsCarousel section', () {
    test(
      'emits loading then the products, fetched by occasionId when the section has one',
      () async {
        when(mockGetHomeSectionsUseCase()).thenAnswer(
          (_) async => const SuccessResponse([carouselByOccasionSection]),
        );
        const product = ProductEntity(id: 'p1', name: 'Rose Bouquet');
        when(
          mockGetProductsUseCase(
            occasionId: 'occ-1',
            pageNumber: 1,
            pageSize: 20,
          ),
        ).thenAnswer((_) async => SuccessResponse(paginatedOf([product])));

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            isA<HomeState>().having(
              (s) => s.sectionsResource.isLoading,
              'sectionsResource.isLoading',
              true,
            ),
            isA<HomeState>().having(
              (s) => s.sectionsResource.isSuccess,
              'sectionsResource.isSuccess',
              true,
            ),
            isA<HomeState>().having(
              (s) =>
                  s.carouselResources[carouselByOccasionSection.id]
                      ?.isLoading,
              'carousel.isLoading',
              true,
            ),
            isA<HomeState>()
                .having(
                  (s) =>
                      s
                          .carouselResources[carouselByOccasionSection.id]
                          ?.isSuccess,
                  'carousel.isSuccess',
                  true,
                )
                .having(
                  (s) =>
                      s.carouselResources[carouselByOccasionSection.id]?.data,
                  'carousel.data',
                  [product],
                ),
          ]),
        );
        final acting = cubit.doEvents(HomeStarted());
        await expectation;
        await acting;

        verifyNever(
          mockGetProductsByCategoryUseCase(categoryId: anyNamed('categoryId')),
        );
      },
    );

    test('falls back to categoryId when there is no occasionId', () async {
      when(mockGetHomeSectionsUseCase()).thenAnswer(
        (_) async => const SuccessResponse([carouselByCategorySection]),
      );
      const product = ProductEntity(id: 'p2', name: 'Tulip Bunch');
      when(
        mockGetProductsByCategoryUseCase(categoryId: 'cat-1'),
      ).thenAnswer((_) async => const SuccessResponse([product]));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HomeState>().having(
            (s) => s.sectionsResource.isLoading,
            'sectionsResource.isLoading',
            true,
          ),
          isA<HomeState>().having(
            (s) => s.sectionsResource.isSuccess,
            'sectionsResource.isSuccess',
            true,
          ),
          isA<HomeState>().having(
            (s) =>
                s.carouselResources[carouselByCategorySection.id]?.isLoading,
            'carousel.isLoading',
            true,
          ),
          isA<HomeState>()
              .having(
                (s) =>
                    s
                        .carouselResources[carouselByCategorySection.id]
                        ?.isSuccess,
                'carousel.isSuccess',
                true,
              )
              .having(
                (s) =>
                    s.carouselResources[carouselByCategorySection.id]?.data,
                'carousel.data',
                [product],
              ),
        ]),
      );
      final acting = cubit.doEvents(HomeStarted());
      await expectation;
      await acting;
    });

    test(
      'multiple concurrent carousels resolve in completion order, each keeping its own data',
      () async {
        const secondCarouselSection = HomeSectionEntity(
          id: 'section-carousel-occasion-2',
          type: HomeSectionType.productsCarousel,
          index: 6,
          isActive: true,
          occasionId: 'occ-2',
        );
        const productA = ProductEntity(id: 'pA', name: 'A');
        const productB = ProductEntity(id: 'pB', name: 'B');

        when(mockGetHomeSectionsUseCase()).thenAnswer(
          (_) async => const SuccessResponse([
            carouselByOccasionSection,
            secondCarouselSection,
          ]),
        );
        // occ-1 resolves after occ-2, on purpose: if _emitCarousel read a
        // stale `state` captured before either await, the later (occ-1)
        // emission would clobber occ-2's already-landed entry — this is
        // an empirical check for that, not just a final-state assertion.
        when(
          mockGetProductsUseCase(
            occasionId: 'occ-1',
            pageNumber: 1,
            pageSize: 20,
          ),
        ).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 20));
          return SuccessResponse(paginatedOf([productA]));
        });
        when(
          mockGetProductsUseCase(
            occasionId: 'occ-2',
            pageNumber: 1,
            pageSize: 20,
          ),
        ).thenAnswer((_) async => SuccessResponse(paginatedOf([productB])));

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            isA<HomeState>().having(
              (s) => s.sectionsResource.isLoading,
              'sectionsResource.isLoading',
              true,
            ),
            isA<HomeState>().having(
              (s) => s.sectionsResource.isSuccess,
              'sectionsResource.isSuccess',
              true,
            ),
            isA<HomeState>().having(
              (s) =>
                  s.carouselResources[carouselByOccasionSection.id]
                      ?.isLoading,
              'occ-1 carousel.isLoading',
              true,
            ),
            isA<HomeState>().having(
              (s) => s.carouselResources[secondCarouselSection.id]?.isLoading,
              'occ-2 carousel.isLoading',
              true,
            ),
            // occ-2 has no delay, so it lands before occ-1 despite being
            // started second.
            isA<HomeState>()
                .having(
                  (s) =>
                      s.carouselResources[secondCarouselSection.id]?.data,
                  'occ-2 carousel.data',
                  [productB],
                )
                .having(
                  (s) =>
                      s
                          .carouselResources[carouselByOccasionSection.id]
                          ?.isLoading,
                  'occ-1 carousel still loading',
                  true,
                ),
            isA<HomeState>()
                .having(
                  (s) =>
                      s.carouselResources[carouselByOccasionSection.id]?.data,
                  'occ-1 carousel.data',
                  [productA],
                )
                .having(
                  (s) => s.carouselResources[secondCarouselSection.id]?.data,
                  'occ-2 carousel.data still present',
                  [productB],
                ),
          ]),
        );
        final acting = cubit.doEvents(HomeStarted());
        await expectation;
        await acting;
      },
    );

    test('emits loading then an error when the section has neither filter', () async {
      when(mockGetHomeSectionsUseCase()).thenAnswer(
        (_) async => const SuccessResponse([carouselWithNoFilterSection]),
      );

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HomeState>().having(
            (s) => s.sectionsResource.isLoading,
            'sectionsResource.isLoading',
            true,
          ),
          isA<HomeState>().having(
            (s) => s.sectionsResource.isSuccess,
            'sectionsResource.isSuccess',
            true,
          ),
          isA<HomeState>().having(
            (s) =>
                s.carouselResources[carouselWithNoFilterSection.id]
                    ?.isLoading,
            'carousel.isLoading',
            true,
          ),
          isA<HomeState>().having(
            (s) => s.carouselResources[carouselWithNoFilterSection.id]?.isError,
            'carousel.isError',
            true,
          ),
        ]),
      );
      final acting = cubit.doEvents(HomeStarted());
      await expectation;
      await acting;

      verifyNever(
        mockGetProductsUseCase(
          occasionId: anyNamed('occasionId'),
          pageNumber: anyNamed('pageNumber'),
          pageSize: anyNamed('pageSize'),
        ),
      );
      verifyNever(
        mockGetProductsByCategoryUseCase(categoryId: anyNamed('categoryId')),
      );
    });
  });

  group('BestSeller section', () {
    test(
      'emits loading then fetches products per occasion, keeping only isBestSeller ones',
      () async {
        when(mockGetHomeSectionsUseCase()).thenAnswer(
          (_) async => const SuccessResponse([bestSellerSection]),
        );
        when(
          mockGetOccasionsUseCase(pageNumber: 1, pageSize: 50),
        ).thenAnswer((_) async => SuccessResponse(paginatedOf([occasion])));

        const bestSeller = ProductEntity(
          id: 'p1',
          name: 'Red Roses',
          isBestSeller: true,
        );
        const regular = ProductEntity(
          id: 'p2',
          name: 'Daisy Bunch',
          isBestSeller: false,
        );
        when(
          mockGetProductsUseCase(
            occasionId: 'occ-1',
            pageNumber: 1,
            pageSize: 20,
          ),
        ).thenAnswer(
          (_) async => SuccessResponse(paginatedOf([bestSeller, regular])),
        );

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            isA<HomeState>().having(
              (s) => s.sectionsResource.isLoading,
              'sectionsResource.isLoading',
              true,
            ),
            isA<HomeState>().having(
              (s) => s.sectionsResource.isSuccess,
              'sectionsResource.isSuccess',
              true,
            ),
            isA<HomeState>().having(
              (s) => s.bestSellerResource.isLoading,
              'bestSellerResource.isLoading',
              true,
            ),
            isA<HomeState>()
                .having(
                  (s) => s.bestSellerResource.isSuccess,
                  'bestSellerResource.isSuccess',
                  true,
                )
                .having(
                  (s) => s.bestSellerResource.data,
                  'bestSellerResource.data',
                  [bestSeller],
                ),
          ]),
        );
        final acting = cubit.doEvents(HomeStarted());
        await expectation;
        await acting;
      },
    );

    test('emits loading then an error when fetching occasions fails', () async {
      when(mockGetHomeSectionsUseCase()).thenAnswer(
        (_) async => const SuccessResponse([bestSellerSection]),
      );
      when(
        mockGetOccasionsUseCase(pageNumber: 1, pageSize: 50),
      ).thenAnswer((_) async => ErrorResponse(errMessage: 'network down'));

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<HomeState>().having(
            (s) => s.sectionsResource.isLoading,
            'sectionsResource.isLoading',
            true,
          ),
          isA<HomeState>().having(
            (s) => s.sectionsResource.isSuccess,
            'sectionsResource.isSuccess',
            true,
          ),
          isA<HomeState>().having(
            (s) => s.bestSellerResource.isLoading,
            'bestSellerResource.isLoading',
            true,
          ),
          isA<HomeState>()
              .having(
                (s) => s.bestSellerResource.isError,
                'bestSellerResource.isError',
                true,
              )
              .having(
                (s) => s.bestSellerResource.errorMessage,
                'bestSellerResource.errorMessage',
                'network down',
              ),
        ]),
      );
      final acting = cubit.doEvents(HomeStarted());
      await expectation;
      await acting;
    });

    test(
      'emits loading then an error instead of hanging when a per-occasion fetch throws',
      () async {
        when(mockGetHomeSectionsUseCase()).thenAnswer(
          (_) async => const SuccessResponse([bestSellerSection]),
        );
        when(
          mockGetOccasionsUseCase(pageNumber: 1, pageSize: 50),
        ).thenAnswer((_) async => SuccessResponse(paginatedOf([occasion])));
        when(
          mockGetProductsUseCase(
            occasionId: 'occ-1',
            pageNumber: 1,
            pageSize: 20,
          ),
        ).thenThrow(Exception('unexpected parse failure'));

        final expectation = expectLater(
          cubit.stream,
          emitsInOrder([
            isA<HomeState>().having(
              (s) => s.sectionsResource.isLoading,
              'sectionsResource.isLoading',
              true,
            ),
            isA<HomeState>().having(
              (s) => s.sectionsResource.isSuccess,
              'sectionsResource.isSuccess',
              true,
            ),
            isA<HomeState>().having(
              (s) => s.bestSellerResource.isLoading,
              'bestSellerResource.isLoading',
              true,
            ),
            isA<HomeState>().having(
              (s) => s.bestSellerResource.isError,
              'bestSellerResource.isError',
              true,
            ),
          ]),
        );
        final acting = cubit.doEvents(HomeStarted());
        await expectation;
        await acting;
      },
    );
  });
}
