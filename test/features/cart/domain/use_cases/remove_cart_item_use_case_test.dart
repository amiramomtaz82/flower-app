import 'package:dio/dio.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/cart/domain/entities/cart_entity.dart';
import 'package:flower_app/features/cart/domain/repo/cart_repo.dart';
import 'package:flower_app/features/cart/domain/use_cases/remove_cart_item_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'remove_cart_item_use_case_test.mocks.dart';

@GenerateMocks([CartRepo])
void main() {
  late RemoveCartItemUseCase removeCartItemUseCase;
  late MockCartRepo mockCartRepo;

  setUpAll(() {
    provideDummy<BaseResponse<CartEntity>>(const SuccessResponse(CartEntity()));
  });

  setUp(() {
    mockCartRepo = MockCartRepo();
    removeCartItemUseCase = RemoveCartItemUseCase(mockCartRepo);
  });

  test('delegates to CartRepo keyed by cart item id, not product id', () async {
    // Arrange
    const cart = CartEntity(id: 'cart-1');
    when(
      mockCartRepo.removeCartItem(cartItemId: anyNamed('cartItemId')),
    ).thenAnswer((_) async => const SuccessResponse(cart));

    // Act
    final result = await removeCartItemUseCase(cartItemId: 'item-1');

    // Assert
    expect(result, isA<SuccessResponse<CartEntity>>());
    expect((result as SuccessResponse<CartEntity>).data, cart);
    verify(mockCartRepo.removeCartItem(cartItemId: 'item-1')).called(1);
  });

  test('returns ErrorResponse when CartRepo.removeCartItem fails', () async {
    // Arrange
    when(
      mockCartRepo.removeCartItem(cartItemId: anyNamed('cartItemId')),
    ).thenAnswer(
      (_) async => ErrorResponse(
        error: DioException(requestOptions: RequestOptions(path: '')),
      ),
    );

    // Act
    final result = await removeCartItemUseCase(cartItemId: 'item-1');

    // Assert
    expect(result, isA<ErrorResponse<CartEntity>>());
  });
}
