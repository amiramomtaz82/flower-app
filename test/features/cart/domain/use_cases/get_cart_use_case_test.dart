import 'package:dio/dio.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/cart/domain/entities/cart_entity.dart';
import 'package:flower_app/features/cart/domain/repo/cart_repo.dart';
import 'package:flower_app/features/cart/domain/use_cases/get_cart_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_cart_use_case_test.mocks.dart';

@GenerateMocks([CartRepo])
void main() {
  late GetCartUseCase getCartUseCase;
  late MockCartRepo mockCartRepo;

  setUpAll(() {
    provideDummy<BaseResponse<CartEntity>>(const SuccessResponse(CartEntity()));
  });

  setUp(() {
    mockCartRepo = MockCartRepo();
    getCartUseCase = GetCartUseCase(mockCartRepo);
  });

  test('delegates to CartRepo.getCart and returns SuccessResponse', () async {
    // Arrange
    const cart = CartEntity(id: 'cart-1', subtotal: 300, total: 300);
    when(
      mockCartRepo.getCart(),
    ).thenAnswer((_) async => const SuccessResponse(cart));

    // Act
    final result = await getCartUseCase();

    // Assert
    expect(result, isA<SuccessResponse<CartEntity>>());
    expect((result as SuccessResponse<CartEntity>).data, cart);
    verify(mockCartRepo.getCart()).called(1);
  });

  test('returns ErrorResponse when CartRepo.getCart fails', () async {
    // Arrange
    when(mockCartRepo.getCart()).thenAnswer(
      (_) async => ErrorResponse(
        error: DioException(requestOptions: RequestOptions(path: '')),
      ),
    );

    // Act
    final result = await getCartUseCase();

    // Assert
    expect(result, isA<ErrorResponse<CartEntity>>());
  });
}
