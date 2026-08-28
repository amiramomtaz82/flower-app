import 'dart:async';

import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';
import 'package:flower_app/core/pagination/pagination_model.dart';
import 'package:flower_app/features/commerce/domain/entities/occasion_entity.dart';
import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_occasions_use_case.dart';
import 'package:flower_app/features/commerce/domain/use_cases/get_products_use_case.dart';
import 'package:flower_app/features/commerce/presentation/occasions/manager/occasions_cubit.dart';
import 'package:flower_app/features/commerce/presentation/occasions/manager/occasions_events.dart';
import 'package:flower_app/features/commerce/presentation/occasions/view/occasions_view.dart';
import 'package:flower_app/features/commerce/presentation/widgets/custom_product_card.dart';
import 'package:flower_app/features/commerce/presentation/widgets/selection_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'occasions_view_test.mocks.dart';

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

// The view is driven through a real cubit with mocked use cases, so the test
// covers the wiring between the two rather than a stubbed-out state.
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
    ProductEntity(id: 'p1', name: 'Birthday Bouquet', price: 300, currency: 'EGP'),
  ];
  const weddingProducts = <ProductEntity>[
    ProductEntity(id: 'p2', name: 'Wedding Centerpiece', price: 900, currency: 'EGP'),
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

  Future<void> pumpView(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<OccasionsCubit>.value(
          value: cubit,
          child: const OccasionsView(),
        ),
      ),
    );
  }

  // the page is pushed over Home, so the bar and its back arrow are part of it
  group('Occasions App Bar Test', () {
    testWidgets('shows the title and a back arrow in every state', (
      tester,
    ) async {
      // Arrange
      stubOccasions(
        ErrorResponse<PaginatedResponse<OccasionEntity>>(
          errMessage: 'No internet connection',
        ),
      );

      // Act
      await cubit.doEvents(OccasionsStarted());
      await pumpView(tester);

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Occasion'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });
  });

  // the three states the page can be in before any tab is drawn
  group('Occasions List States Test', () {
    testWidgets('shows a spinner while the occasions are loading', (
      tester,
    ) async {
      // Arrange: the request is left hanging so the loading state stays put
      final pending =
          Completer<BaseResponse<PaginatedResponse<OccasionEntity>>>();
      when(
        mockGetOccasionsUseCase(
          pageNumber: anyNamed('pageNumber'),
          pageSize: anyNamed('pageSize'),
        ),
      ).thenAnswer((_) => pending.future);

      // Act
      await pumpView(tester);
      unawaited(cubit.doEvents(OccasionsStarted()));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(SelectionTabs), findsNothing);
    });

    testWidgets('shows the error message when the occasions fail', (
      tester,
    ) async {
      // Arrange
      stubOccasions(
        ErrorResponse<PaginatedResponse<OccasionEntity>>(
          errMessage: 'No internet connection',
        ),
      );

      // Act
      await cubit.doEvents(OccasionsStarted());
      await pumpView(tester);

      // Assert
      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.byType(SelectionTabs), findsNothing);
    });

    testWidgets('shows an empty message when there are no occasions', (
      tester,
    ) async {
      // Arrange
      stubOccasions(SuccessResponse(onePageOf(<OccasionEntity>[])));

      // Act
      await cubit.doEvents(OccasionsStarted());
      await pumpView(tester);

      // Assert
      expect(find.text('No occasions yet'), findsOneWidget);
      expect(find.byType(SelectionTabs), findsNothing);
    });
  });

  // the loaded page: subtitle, tabs, then the selected occasion's products
  group('Occasions Content Test', () {
    testWidgets('renders the subtitle, a tab per occasion and its products', (
      tester,
    ) async {
      // Arrange
      stubOccasions(SuccessResponse(onePageOf(occasions)));
      stubProducts('o1', SuccessResponse(onePageOf(birthdayProducts)));

      // Act
      await cubit.doEvents(OccasionsStarted());
      await pumpView(tester);

      // Assert
      expect(find.text('Bloom with our exquisite best sellers'), findsOneWidget);
      expect(find.byType(SelectionTabs), findsOneWidget);
      expect(find.text('Birthday'), findsOneWidget);
      expect(find.text('Wedding'), findsOneWidget);
      expect(find.byType(CustomProductCard), findsOneWidget);
      expect(find.text('Birthday Bouquet'), findsOneWidget);
    });

    testWidgets('shows an empty message when the occasion has no products', (
      tester,
    ) async {
      // Arrange
      stubOccasions(SuccessResponse(onePageOf(occasions)));
      stubProducts('o1', SuccessResponse(onePageOf(<ProductEntity>[])));

      // Act
      await cubit.doEvents(OccasionsStarted());
      await pumpView(tester);

      // Assert
      expect(find.text('No products for this occasion yet'), findsOneWidget);
      expect(find.byType(CustomProductCard), findsNothing);
      // the tabs stay put, so the user can pick another occasion
      expect(find.byType(SelectionTabs), findsOneWidget);
    });

    testWidgets('shows the error message when the products fail', (
      tester,
    ) async {
      // Arrange
      stubOccasions(SuccessResponse(onePageOf(occasions)));
      stubProducts(
        'o1',
        ErrorResponse<PaginatedResponse<ProductEntity>>(
          errMessage: 'Server error',
        ),
      );

      // Act
      await cubit.doEvents(OccasionsStarted());
      await pumpView(tester);

      // Assert
      expect(find.text('Server error'), findsOneWidget);
      expect(find.byType(SelectionTabs), findsOneWidget);
    });
  });

  // tapping a tab has to reach the cubit and swap the grid
  group('Tab Tap Test', () {
    testWidgets('tapping a tab loads and shows that occasion products', (
      tester,
    ) async {
      // Arrange
      stubOccasions(SuccessResponse(onePageOf(occasions)));
      stubProducts('o1', SuccessResponse(onePageOf(birthdayProducts)));
      stubProducts('o2', SuccessResponse(onePageOf(weddingProducts)));
      await cubit.doEvents(OccasionsStarted());
      await pumpView(tester);

      // Act
      await tester.tap(find.text('Wedding'));
      await tester.pump(); // dispatch the tap
      await tester.pump(); // rebuild once the products come back

      // Assert
      expect(cubit.state.selectedOccasionId, 'o2');
      expect(find.text('Wedding Centerpiece'), findsOneWidget);
      expect(find.text('Birthday Bouquet'), findsNothing);

      verify(
        mockGetProductsUseCase(
          occasionId: 'o2',
          pageNumber: anyNamed('pageNumber'),
          pageSize: anyNamed('pageSize'),
        ),
      ).called(1);
    });
  });
}
