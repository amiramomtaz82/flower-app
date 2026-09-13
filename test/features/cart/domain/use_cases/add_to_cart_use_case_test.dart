import 'package:dio/dio.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/cart/domain/entities/cart_entity.dart';
import 'package:flower_app/features/cart/domain/repo/cart_repo.dart';
import 'package:flower_app/features/cart/domain/use_cases/add_to_cart_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'add_to_cart_use_case_test.mocks.dart';

@GenerateMocks([CartRepo])
void main() {
  late AddToCartUseCase addToCartUseCase;
  late MockCartRepo mockCartRepo;

  setUpAll(() {
    provideDummy<BaseResponse<CartEntity>>(const SuccessResponse(CartEntity()));
  });

  setUp(() {
    mockCartRepo = MockCartRepo();
    addToCartUseCase = AddToCartUseCase(mockCartRepo);
  });

  test('delegates to CartRepo.addToCart and returns SuccessResponse', () async {
    // Arrange
    const cart = CartEntity(id: 'cart-1', subtotal: 300, total: 300);
    when(
      mockCartRepo.addToCart(
        productId: anyNamed('productId'),
        quantity: anyNamed('quantity'),
      ),
    ).thenAnswer((_) async => const SuccessResponse(cart));

    // Act
    final result = await addToCartUseCase(productId: 'product-1', quantity: 3);

    // Assert
    expect(result, isA<SuccessResponse<CartEntity>>());
    expect((result as SuccessResponse<CartEntity>).data, cart);
    verify(
      mockCartRepo.addToCart(productId: 'product-1', quantity: 3),
    ).called(1);
  });

  test('adds a single unit when no quantity is given', () async {
    // Arrange
    when(
      mockCartRepo.addToCart(
        productId: anyNamed('productId'),
        quantity: anyNamed('quantity'),
      ),
    ).thenAnswer((_) async => const SuccessResponse(CartEntity()));

    // Act
    await addToCartUseCase(productId: 'product-1');

    // Assert
    verify(
      mockCartRepo.addToCart(productId: 'product-1', quantity: 1),
    ).called(1);
  });

  test('returns ErrorResponse when CartRepo.addToCart fails', () async {
    // Arrange
    when(
      mockCartRepo.addToCart(
        productId: anyNamed('productId'),
        quantity: anyNamed('quantity'),
      ),
    ).thenAnswer(
      (_) async => ErrorResponse(
        error: DioException(requestOptions: RequestOptions(path: '')),
      ),
    );

    // Act
    final result = await addToCartUseCase(productId: 'product-1', quantity: 1);

    // Assert
    expect(result, isA<ErrorResponse<CartEntity>>());
  });
}
