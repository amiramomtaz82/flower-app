import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/config/resource/rsource.dart';
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
import 'package:flower_app/features/commerce/domain/use_cases/get_products_use_case.dart';
import 'package:flower_app/features/commerce/presentation/home/manager/home_cubit.dart';
import 'package:flower_app/features/commerce/presentation/home/manager/home_events.dart';
import 'package:flower_app/features/commerce/presentation/home/manager/home_state.dart';
import 'package:flower_app/features/notifications/domain/usecase/sync_notification_permission_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetHomeSectionsUseCase extends Mock implements GetHomeSectionsUseCase {}

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class MockGetOccasionsUseCase extends Mock implements GetOccasionsUseCase {}

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

class MockSyncNotificationPermissionUseCase extends Mock
    implements SyncNotificationPermissionUseCase {}

void main() {
  late MockGetHomeSectionsUseCase mockGetHomeSectionsUseCase;
  late MockGetCategoriesUseCase mockGetCategoriesUseCase;
  late MockGetOccasionsUseCase mockGetOccasionsUseCase;
  late MockGetProductsUseCase mockGetProductsUseCase;
  late MockSyncNotificationPermissionUseCase mockSyncNotificationPermissionUseCase;
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
  const occasion = OccasionEntity(
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

  setUp(() {
    mockGetHomeSectionsUseCase = MockGetHomeSectionsUseCase();
    mockGetCategoriesUseCase = MockGetCategoriesUseCase();
    mockGetOccasionsUseCase = MockGetOccasionsUseCase();
    mockGetProductsUseCase = MockGetProductsUseCase();
    mockSyncNotificationPermissionUseCase =
        MockSyncNotificationPermissionUseCase();

    when(() => mockSyncNotificationPermissionUseCase())
        .thenAnswer((_) async => null);

    when(() => mockGetOccasionsUseCase(
          pageNumber: any(named: 'pageNumber'),
          pageSize: any(named: 'pageSize'),
        )).thenAnswer(
        (_) async => SuccessResponse(paginatedOf(const <OccasionEntity>[])));

    when(() => mockGetProductsUseCase(
          occasionId: any(named: 'occasionId'),
          categoryId: any(named: 'categoryId'),
          pageNumber: any(named: 'pageNumber'),
          pageSize: any(named: 'pageSize'),
        )).thenAnswer(
        (_) async => SuccessResponse(paginatedOf(const <ProductEntity>[])));

    cubit = HomeCubit(
      mockGetHomeSectionsUseCase,
      mockGetCategoriesUseCase,
      mockGetOccasionsUseCase,
      mockSyncNotificationPermissionUseCase,
      mockGetProductsUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('HomeStarted', () {
    test('emits whatever sections the use case returns and loads each one', () async {
      when(() => mockGetHomeSectionsUseCase()).thenAnswer(
        (_) async => const SuccessResponse([
          categoriesSection,
          occasionsSection,
        ]),
      );
      when(() => mockGetCategoriesUseCase()).thenAnswer(
        (_) async => const SuccessResponse(<CategoryEntity>[]),
      );

      await cubit.doEvents(HomeStarted());

      expect(cubit.state.sectionsResource.isSuccess, true);
      expect(cubit.state.sectionsResource.data, [
        categoriesSection,
        occasionsSection,
      ]);
      verify(() => mockGetCategoriesUseCase()).called(1);
      verify(() => mockSyncNotificationPermissionUseCase()).called(1);
    });

    test('emits loading then an error when fetching sections fails', () async {
      when(() => mockGetHomeSectionsUseCase()).thenAnswer(
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

  group('NotificationPermissionRequested Event', () {
    test('calls syncNotificationPermissionUseCase', () async {
      when(() => mockSyncNotificationPermissionUseCase())
          .thenAnswer((_) async => null);

      await cubit.doEvents(NotificationPermissionRequested());

      verify(() => mockSyncNotificationPermissionUseCase()).called(1);
    });
  });

  group('Categories section', () {
    test('emits loading then the categories on success', () async {
      when(() => mockGetHomeSectionsUseCase()).thenAnswer(
        (_) async => const SuccessResponse([categoriesSection]),
      );
      const roses = CategoryEntity(id: '1', name: 'Roses', icon: 'roses.png');
      when(() => mockGetCategoriesUseCase())
          .thenAnswer((_) async => const SuccessResponse([roses]));

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
      when(() => mockGetHomeSectionsUseCase()).thenAnswer(
        (_) async => const SuccessResponse([occasionsSection]),
      );
      when(() => mockGetOccasionsUseCase(pageNumber: 1, pageSize: 20))
          .thenAnswer((_) async => SuccessResponse(paginatedOf([occasion])));

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
        when(() => mockGetHomeSectionsUseCase()).thenAnswer(
          (_) async => const SuccessResponse([carouselByOccasionSection]),
        );
        const product = ProductEntity(id: 'p1', name: 'Rose Bouquet');
        when(() => mockGetProductsUseCase(
              occasionId: 'occ-1',
              pageNumber: 1,
              pageSize: 20,
            )).thenAnswer((_) async => SuccessResponse(paginatedOf([product])));

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
                  s.carouselResources[carouselByOccasionSection.id]?.isLoading,
              'carousel.isLoading',
              true,
            ),
            isA<HomeState>()
                .having(
                  (s) =>
                      s.carouselResources[carouselByOccasionSection.id]
                          ?.isSuccess,
                  'carousel.isSuccess',
                  true,
                )
                .having(
                  (s) => s
                      .carouselResources[carouselByOccasionSection.id]?.data,
                  'carousel.data',
                  [product],
                ),
          ]),
        );
        final acting = cubit.doEvents(HomeStarted());
        await expectation;
        await acting;
      },
    );

    test('falls back to categoryId when there is no occasionId', () async {
      when(() => mockGetHomeSectionsUseCase()).thenAnswer(
        (_) async => const SuccessResponse([carouselByCategorySection]),
      );
      const product = ProductEntity(id: 'p2', name: 'Tulip Bunch');
      when(() => mockGetProductsUseCase(
            categoryId: 'cat-1',
            pageNumber: 1,
            pageSize: 20,
          )).thenAnswer((_) async => SuccessResponse(paginatedOf([product])));

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
                    s.carouselResources[carouselByCategorySection.id]
                        ?.isSuccess,
                'carousel.isSuccess',
                true,
              )
              .having(
                (s) => s
                    .carouselResources[carouselByCategorySection.id]?.data,
                'carousel.data',
                [product],
              ),
        ]),
      );
      final acting = cubit.doEvents(HomeStarted());
      await expectation;
      await acting;
    });

    test('emits loading then an error when the section has neither filter', () async {
      when(() => mockGetHomeSectionsUseCase()).thenAnswer(
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
                s.carouselResources[carouselWithNoFilterSection.id]?.isLoading,
            'carousel.isLoading',
            true,
          ),
          isA<HomeState>().having(
            (s) =>
                s.carouselResources[carouselWithNoFilterSection.id]?.isError,
            'carousel.isError',
            true,
          ),
        ]),
      );
      final acting = cubit.doEvents(HomeStarted());
      await expectation;
      await acting;
    });
  });

  group('BestSeller section', () {
    test(
      'emits loading then fetches products per occasion, keeping only isBestSeller ones',
      () async {
        when(() => mockGetHomeSectionsUseCase()).thenAnswer(
          (_) async => const SuccessResponse([bestSellerSection]),
        );
        when(() => mockGetOccasionsUseCase(pageNumber: 1, pageSize: 50))
            .thenAnswer((_) async => SuccessResponse(paginatedOf([occasion])));

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
        when(() => mockGetProductsUseCase(
              occasionId: 'occ-1',
              pageNumber: 1,
              pageSize: 20,
            )).thenAnswer(
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
      when(() => mockGetHomeSectionsUseCase()).thenAnswer(
        (_) async => const SuccessResponse([bestSellerSection]),
      );
      when(() => mockGetOccasionsUseCase(pageNumber: 1, pageSize: 50))
          .thenAnswer((_) async => ErrorResponse(errMessage: 'network down'));

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
  });
}
