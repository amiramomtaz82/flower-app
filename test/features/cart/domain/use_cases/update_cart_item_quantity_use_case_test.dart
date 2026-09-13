import 'package:dio/dio.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/cart/domain/entities/cart_entity.dart';
import 'package:flower_app/features/cart/domain/repo/cart_repo.dart';
import 'package:flower_app/features/cart/domain/use_cases/update_cart_item_quantity_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'update_cart_item_quantity_use_case_test.mocks.dart';

@GenerateMocks([CartRepo])
void main() {
  late UpdateCartItemQuantityUseCase updateCartItemQuantityUseCase;
  late MockCartRepo mockCartRepo;

  setUpAll(() {
    provideDummy<BaseResponse<CartEntity>>(const SuccessResponse(CartEntity()));
  });

  setUp(() {
    mockCartRepo = MockCartRepo();
    updateCartItemQuantityUseCase = UpdateCartItemQuantityUseCase(mockCartRepo);
  });

  test('delegates to CartRepo keyed by product id, not cart item id', () async {
    // Arrange
    const cart = CartEntity(id: 'cart-1', subtotal: 750, total: 750);
    when(
      mockCartRepo.updateCartItemQuantity(
        productId: anyNamed('productId'),
        quantity: anyNamed('quantity'),
      ),
    ).thenAnswer((_) async => const SuccessResponse(cart));

    // Act
    final result = await updateCartItemQuantityUseCase(
      productId: 'product-1',
      quantity: 5,
    );

    // Assert
    expect(result, isA<SuccessResponse<CartEntity>>());
    expect((result as SuccessResponse<CartEntity>).data, cart);
    verify(
      mockCartRepo.updateCartItemQuantity(productId: 'product-1', quantity: 5),
    ).called(1);
  });

  test('passes a zero quantity through, which the backend treats as a removal',
      () async {
    // Arrange
    when(
      mockCartRepo.updateCartItemQuantity(
        productId: anyNamed('productId'),
        quantity: anyNamed('quantity'),
      ),
    ).thenAnswer((_) async => const SuccessResponse(CartEntity()));

    // Act
    await updateCartItemQuantityUseCase(productId: 'product-1', quantity: 0);

    // Assert
    verify(
      mockCartRepo.updateCartItemQuantity(productId: 'product-1', quantity: 0),
    ).called(1);
  });

  test('returns ErrorResponse when the repo fails', () async {
    // Arrange
    when(
      mockCartRepo.updateCartItemQuantity(
        productId: anyNamed('productId'),
        quantity: anyNamed('quantity'),
      ),
    ).thenAnswer(
      (_) async => ErrorResponse(
        error: DioException(requestOptions: RequestOptions(path: '')),
      ),
    );

    // Act
    final result = await updateCartItemQuantityUseCase(
      productId: 'product-1',
      quantity: 5,
    );

    // Assert
    expect(result, isA<ErrorResponse<CartEntity>>());
  });
}
