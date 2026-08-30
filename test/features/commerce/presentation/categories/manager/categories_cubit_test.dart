// import 'dart:async';
// 
// import 'package:flower_app/config/base_response/base_response.dart';
// import 'package:flower_app/config/resource/rsource.dart';
// import 'package:flower_app/features/commerce/domain/entities/category_entity.dart';
// import 'package:flower_app/features/commerce/domain/entities/product_entity.dart';
// import 'package:flower_app/features/commerce/domain/use_cases/get_categories_use_case.dart';
// import 'package:flower_app/features/commerce/domain/use_cases/get_products_by_category_use_case.dart';
// import 'package:flower_app/features/commerce/presentation/categories/manager/categories_cubit.dart';
// import 'package:flower_app/features/commerce/presentation/categories/manager/categories_events.dart';
// import 'package:flower_app/features/commerce/presentation/categories/manager/categories_state.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// 
// import 'categories_cubit_test.mocks.dart';
// 
// // Mocking the two use cases the cubit depends on
// @GenerateMocks([GetCategoriesUseCase, GetProductsUseCase])
// void main() {
//   late MockGetCategoriesUseCase mockGetCategoriesUseCase;
//   late MockGetProductsUseCase mockGetProductsUseCase;
//   late CategoriesCubit cubit;
// 
//   const roses = CategoryEntity(id: 'c1', name: 'Roses', icon: 'roses.png');
//   const tulips = CategoryEntity(id: 'c2', name: 'Tulips', icon: 'tulips.png');
//   const categories = <CategoryEntity>[roses, tulips];
// 
//   const rosesProducts = <ProductEntity>[
//     ProductEntity(id: 'p1', name: 'Red Rose Bouquet', price: 250),
//   ];
//   const tulipsProducts = <ProductEntity>[
//     ProductEntity(id: 'p2', name: 'White Tulip Box', price: 400),
//   ];
// 
//   // mockito cannot build a value of a sealed type on its own
//   setUpAll(() {
//     provideDummy<BaseResponse<List<CategoryEntity>>>(
//       const SuccessResponse(<CategoryEntity>[]),
//     );
//     provideDummy<BaseResponse<List<ProductEntity>>>(
//       const SuccessResponse(<ProductEntity>[]),
//     );
//   });
// 
//   // setup before each test, so mocks/stubs never leak between tests
//   setUp(() {
//     mockGetCategoriesUseCase = MockGetCategoriesUseCase();
//     mockGetProductsUseCase = MockGetProductsUseCase();
//     cubit = CategoriesCubit(
//       mockGetCategoriesUseCase,
//       mockGetProductsUseCase,
//     );
//   });
// 
//   tearDown(() => cubit.close());
// 
//   void stubCategories(BaseResponse<List<CategoryEntity>> response) {
//     when(mockGetCategoriesUseCase()).thenAnswer((_) async => response);
//   }
// 
//   void stubProducts(
//     String categoryId,
//     BaseResponse<List<ProductEntity>> response,
//   ) {
//     when(
//       mockGetProductsUseCase(categoryId: categoryId),
//     ).thenAnswer((_) async => response);
//   }
// 
//   // opening the page: which tab it lands on, and what it does when the list
//   // comes back empty or fails
//   group('CategoriesStarted Test', () {
//     test('loads the categories and opens on the first one by default', () async {
//       // Arrange
//       stubCategories(const SuccessResponse(categories));
//       stubProducts('c1', const SuccessResponse(rosesProducts));
// 
//       // Act
//       await cubit.doEvents(CategoriesStarted());
// 
//       // Assert
//       expect(cubit.state.categoriesResource.isSuccess, true);
//       expect(cubit.state.categoriesResource.data, categories);
//       expect(cubit.state.selectedCategoryId, 'c1');
//       expect(cubit.state.productsResource.isSuccess, true);
//       expect(cubit.state.productsResource.data, rosesProducts);
// 
//       verify(mockGetCategoriesUseCase()).called(1);
//       verify(mockGetProductsUseCase(categoryId: 'c1')).called(1);
//     });
// 
//     test('opens on the category tapped on Home when it is one of the tabs', () async {
//       // Arrange
//       stubCategories(const SuccessResponse(categories));
//       stubProducts('c2', const SuccessResponse(tulipsProducts));
// 
//       // Act
//       await cubit.doEvents(CategoriesStarted(initialCategoryId: 'c2'));
// 
//       // Assert
//       expect(cubit.state.selectedCategoryId, 'c2');
//       expect(cubit.state.productsResource.data, tulipsProducts);
// 
//       verify(mockGetProductsUseCase(categoryId: 'c2')).called(1);
//       verifyNever(mockGetProductsUseCase(categoryId: 'c1'));
//     });
// 
//     test('falls back to the first category when the id is no longer a tab', () async {
//       // Arrange
//       stubCategories(const SuccessResponse(categories));
//       stubProducts('c1', const SuccessResponse(rosesProducts));
// 
//       // Act
//       await cubit.doEvents(
//         CategoriesStarted(initialCategoryId: 'deleted-category'),
//       );
// 
//       // Assert
//       expect(cubit.state.selectedCategoryId, 'c1');
//       expect(cubit.state.productsResource.data, rosesProducts);
// 
//       verify(mockGetProductsUseCase(categoryId: 'c1')).called(1);
//     });
// 
//     test('never asks for products when the category list comes back empty', () async {
//       // Arrange
//       stubCategories(const SuccessResponse(<CategoryEntity>[]));
// 
//       // Act
//       await cubit.doEvents(CategoriesStarted());
// 
//       // Assert
//       expect(cubit.state.categoriesResource.isSuccess, true);
//       expect(cubit.state.categoriesResource.data, isEmpty);
//       expect(cubit.state.selectedCategoryId, isNull);
//       expect(cubit.state.productsResource.status, ApiStatus.initial);
// 
//       verifyNever(
//         mockGetProductsUseCase(categoryId: anyNamed('categoryId')),
//       );
//     });
// 
//     test('emits the error and never asks for products when the list fails', () async {
//       // Arrange
//       stubCategories(
//         ErrorResponse<List<CategoryEntity>>(errMessage: 'No internet connection'),
//       );
// 
//       // Act
//       await cubit.doEvents(CategoriesStarted());
// 
//       // Assert
//       expect(cubit.state.categoriesResource.isError, true);
//       expect(
//         cubit.state.categoriesResource.errorMessage,
//         'No internet connection',
//       );
//       expect(cubit.state.selectedCategoryId, isNull);
// 
//       verifyNever(
//         mockGetProductsUseCase(categoryId: anyNamed('categoryId')),
//       );
//     });
//   });
// 
//   // tapping a tab
//   group('CategorySelected Test', () {
//     test('emits loading then the products of the tapped category', () async {
//       // Arrange
//       stubProducts('c2', const SuccessResponse(tulipsProducts));
// 
//       // Act
//       final expectation = expectLater(
//         cubit.stream,
//         emitsInOrder([
//           isA<CategoriesState>()
//               .having(
//                 (state) => state.selectedCategoryId,
//                 'selectedCategoryId',
//                 'c2',
//               )
//               .having(
//                 (state) => state.productsResource.isLoading,
//                 'productsResource.isLoading',
//                 true,
//               ),
//           isA<CategoriesState>()
//               .having(
//                 (state) => state.productsResource.isSuccess,
//                 'productsResource.isSuccess',
//                 true,
//               )
//               .having(
//                 (state) => state.productsResource.data,
//                 'productsResource.data',
//                 tulipsProducts,
//               ),
//         ]),
//       );
//       final selecting = cubit.doEvents(CategorySelected('c2'));
//       await expectation;
//       await selecting;
// 
//       // Assert
//       verify(mockGetProductsUseCase(categoryId: 'c2')).called(1);
//     });
// 
//     test('keeps the tab selected and shows the error when products fail', () async {
//       // Arrange
//       stubProducts(
//         'c1',
//         ErrorResponse<List<ProductEntity>>(errMessage: 'Server error'),
//       );
// 
//       // Act
//       await cubit.doEvents(CategorySelected('c1'));
// 
//       // Assert
//       expect(cubit.state.selectedCategoryId, 'c1');
//       expect(cubit.state.productsResource.isError, true);
//       expect(cubit.state.productsResource.errorMessage, 'Server error');
//     });
//   });
// 
//   // a slow response must not overwrite the tab the user has since moved to
//   group('Out Of Order Response Test', () {
//     test('discards a products response whose tab is no longer selected', () async {
//       // Arrange: c1 is left hanging until we release it by hand
//       final slowFirstTap = Completer<BaseResponse<List<ProductEntity>>>();
//       when(
//         mockGetProductsUseCase(categoryId: 'c1'),
//       ).thenAnswer((_) => slowFirstTap.future);
//       stubProducts('c2', const SuccessResponse(tulipsProducts));
// 
//       // Act: tap c1, then tap c2 before c1 comes back
//       final firstTap = cubit.doEvents(CategorySelected('c1'));
//       await cubit.doEvents(CategorySelected('c2'));
//       slowFirstTap.complete(const SuccessResponse(rosesProducts));
//       await firstTap;
// 
//       // Assert
//       expect(cubit.state.selectedCategoryId, 'c2');
//       expect(cubit.state.productsResource.data, tulipsProducts);
//     });
//   });
// }
