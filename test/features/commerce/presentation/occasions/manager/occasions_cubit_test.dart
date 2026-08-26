import 'dart:async';

import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/config/resource/rsource.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/core/pagination/pagination_model.dart';
import 'package:flower_app/features/commerce/domain/entities/occasion_entity.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_occasions_use_case.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_products_use_case.dart';
import 'package:flower_app/features/commerce/presentation/occasions/manager/occasions_cubit.dart';
import 'package:flower_app/features/commerce/presentation/occasions/manager/occasions_events.dart';
import 'package:flower_app/features/commerce/presentation/occasions/manager/occasions_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'occasions_cubit_test.mocks.dart';

/// Both endpoints here are paginated; the cubit only ever reads `data`, so the
/// pagination block is filled in as a single full page.
PaginatedResponse<T> onePageOf<T>(List<T> data) => PaginatedResponse<T>(
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

// Mocking the two use cases the cubit depends on
@GenerateMocks([GetOccasionsUseCase, GetProductsUseCase])
void main() {
  late MockGetOccasionsUseCase mockGetOccasionsUseCase;
  late MockGetProductsUseCase mockGetProductsUseCase;
  late OccasionsCubit cubit;

  const birthday = OccasionEntity(
    id: 'o1',
    name: 'Birthday',
    imageUrl: 'birthday.png',
  );
  const wedding = OccasionEntity(
    id: 'o2',
    name: 'Wedding',
    imageUrl: 'wedding.png',
  );
  const occasions = <OccasionEntity>[birthday, wedding];

  const birthdayProducts = <ProductEntity>[
    ProductEntity(id: 'p1', name: 'Birthday Bouquet', price: 300),
  ];
  const weddingProducts = <ProductEntity>[
    ProductEntity(id: 'p2', name: 'Wedding Centerpiece', price: 900),
  ];

  // mockito cannot build a value of a sealed type on its own
  setUpAll(() {
    provideDummy<BaseResponse<PaginatedResponse<OccasionEntity>>>(
      SuccessResponse(onePageOf(<OccasionEntity>[])),
    );
    provideDummy<BaseResponse<PaginatedResponse<ProductEntity>>>(
      SuccessResponse(onePageOf(<ProductEntity>[])),
    );
  });

  // setup before each test, so mocks/stubs never leak between tests
  setUp(() {
    mockGetOccasionsUseCase = MockGetOccasionsUseCase();
    mockGetProductsUseCase = MockGetProductsUseCase();
    cubit = OccasionsCubit(mockGetOccasionsUseCase, mockGetProductsUseCase);
  });

  tearDown(() => cubit.close());

  void stubOccasions(BaseResponse<PaginatedResponse<OccasionEntity>> response) {
    when(
      mockGetOccasionsUseCase(
        pageNumber: anyNamed('pageNumber'),
        pageSize: anyNamed('pageSize'),
      ),
    ).thenAnswer((_) async => response);
  }

  void stubProducts(
    String occasionId,
    BaseResponse<PaginatedResponse<ProductEntity>> response,
  ) {
    when(
      mockGetProductsUseCase(
        occasionId: occasionId,
        pageNumber: anyNamed('pageNumber'),
        pageSize: anyNamed('pageSize'),
      ),
    ).thenAnswer((_) async => response);
  }

  // opening the page: which tab it lands on, and what it does when the list
  // comes back empty or fails
  group('OccasionsStarted Test', () {
    test('loads the occasions and opens on the first one by default', () async {
      // Arrange
      stubOccasions(SuccessResponse(onePageOf(occasions)));
      stubProducts('o1', SuccessResponse(onePageOf(birthdayProducts)));

      // Act
      await cubit.doEvents(OccasionsStarted());

      // Assert
      expect(cubit.state.occasionsResource.isSuccess, true);
      expect(cubit.state.occasionsResource.data, occasions);
      expect(cubit.state.selectedOccasionId, 'o1');
      expect(cubit.state.productsResource.isSuccess, true);
      expect(cubit.state.productsResource.data, birthdayProducts);

      verify(mockGetOccasionsUseCase(pageNumber: 1, pageSize: 20)).called(1);
      verify(
        mockGetProductsUseCase(occasionId: 'o1', pageNumber: 1, pageSize: 20),
      ).called(1);
    });

    test('opens on the occasion tapped on Home when it is one of the tabs', () async {
      // Arrange
      stubOccasions(SuccessResponse(onePageOf(occasions)));
      stubProducts('o2', SuccessResponse(onePageOf(weddingProducts)));

      // Act
      await cubit.doEvents(OccasionsStarted(initialOccasionId: 'o2'));

      // Assert
      expect(cubit.state.selectedOccasionId, 'o2');
      expect(cubit.state.productsResource.data, weddingProducts);

      verify(
        mockGetProductsUseCase(
          occasionId: 'o2',
          pageNumber: anyNamed('pageNumber'),
          pageSize: anyNamed('pageSize'),
        ),
      ).called(1);
      verifyNever(
        mockGetProductsUseCase(
          occasionId: 'o1',
          pageNumber: anyNamed('pageNumber'),
          pageSize: anyNamed('pageSize'),
        ),
      );
    });

    test('falls back to the first occasion when the id is no longer a tab', () async {
      // Arrange
      stubOccasions(SuccessResponse(onePageOf(occasions)));
      stubProducts('o1', SuccessResponse(onePageOf(birthdayProducts)));

      // Act
      await cubit.doEvents(
        OccasionsStarted(initialOccasionId: 'deleted-occasion'),
      );

      // Assert
      expect(cubit.state.selectedOccasionId, 'o1');
      expect(cubit.state.productsResource.data, birthdayProducts);
    });

    test('never asks for products when the occasion list comes back empty', () async {
      // Arrange
      stubOccasions(SuccessResponse(onePageOf(<OccasionEntity>[])));

      // Act
      await cubit.doEvents(OccasionsStarted());

      // Assert
      expect(cubit.state.occasionsResource.isSuccess, true);
      expect(cubit.state.occasionsResource.data, isEmpty);
      expect(cubit.state.selectedOccasionId, isNull);
      expect(cubit.state.productsResource.status, ApiStatus.initial);

      verifyNever(
        mockGetProductsUseCase(
          occasionId: anyNamed('occasionId'),
          pageNumber: anyNamed('pageNumber'),
          pageSize: anyNamed('pageSize'),
        ),
      );
    });

    test('emits the error and never asks for products when the list fails', () async {
      // Arrange
      stubOccasions(
        ErrorResponse<PaginatedResponse<OccasionEntity>>(
          errMessage: 'No internet connection',
        ),
      );

      // Act
      await cubit.doEvents(OccasionsStarted());

      // Assert
      expect(cubit.state.occasionsResource.isError, true);
      expect(
        cubit.state.occasionsResource.errorMessage,
        'No internet connection',
      );
      expect(cubit.state.selectedOccasionId, isNull);

      verifyNever(
        mockGetProductsUseCase(
          occasionId: anyNamed('occasionId'),
          pageNumber: anyNamed('pageNumber'),
          pageSize: anyNamed('pageSize'),
        ),
      );
    });
  });

  // tapping a tab
  group('OccasionSelected Test', () {
    test('emits loading then the products of the tapped occasion', () async {
      // Arrange
      stubProducts('o2', SuccessResponse(onePageOf(weddingProducts)));

      // Act
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<OccasionsState>()
              .having(
                (state) => state.selectedOccasionId,
                'selectedOccasionId',
                'o2',
              )
              .having(
                (state) => state.productsResource.isLoading,
                'productsResource.isLoading',
                true,
              ),
          isA<OccasionsState>()
              .having(
                (state) => state.productsResource.isSuccess,
                'productsResource.isSuccess',
                true,
              )
              .having(
                (state) => state.productsResource.data,
                'productsResource.data',
                weddingProducts,
              ),
        ]),
      );
      final selecting = cubit.doEvents(OccasionSelected('o2'));
      await expectation;
      await selecting;

      // Assert
      verify(
        mockGetProductsUseCase(occasionId: 'o2', pageNumber: 1, pageSize: 20),
      ).called(1);
    });

    test('keeps the tab selected and shows the error when products fail', () async {
      // Arrange
      stubProducts(
        'o1',
        ErrorResponse<PaginatedResponse<ProductEntity>>(
          errMessage: 'Server error',
        ),
      );

      // Act
      await cubit.doEvents(OccasionSelected('o1'));

      // Assert
      expect(cubit.state.selectedOccasionId, 'o1');
      expect(cubit.state.productsResource.isError, true);
      expect(cubit.state.productsResource.errorMessage, 'Server error');
    });
  });

  // a slow response must not overwrite the tab the user has since moved to
  group('Out Of Order Response Test', () {
    test('discards a products response whose tab is no longer selected', () async {
      // Arrange: o1 is left hanging until we release it by hand
      final slowFirstTap =
          Completer<BaseResponse<PaginatedResponse<ProductEntity>>>();
      when(
        mockGetProductsUseCase(
          occasionId: 'o1',
          pageNumber: anyNamed('pageNumber'),
          pageSize: anyNamed('pageSize'),
        ),
      ).thenAnswer((_) => slowFirstTap.future);
      stubProducts('o2', SuccessResponse(onePageOf(weddingProducts)));

      // Act: tap o1, then tap o2 before o1 comes back
      final firstTap = cubit.doEvents(OccasionSelected('o1'));
      await cubit.doEvents(OccasionSelected('o2'));
      slowFirstTap.complete(SuccessResponse(onePageOf(birthdayProducts)));
      await firstTap;

      // Assert
      expect(cubit.state.selectedOccasionId, 'o2');
      expect(cubit.state.productsResource.data, weddingProducts);
    });
  });
}
