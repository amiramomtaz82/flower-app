import 'package:dio/dio.dart';
import 'package:flower_app/config/base_response/base_response.dart';
import 'package:flower_app/features/cart/data/data_source/remote/cart_remote_data_source.dart';
import 'package:flower_app/features/cart/data/models/add_to_cart_item_request.dart';
import 'package:flower_app/features/cart/data/models/cart_dto.dart';
import 'package:flower_app/features/cart/data/models/cart_item_dto.dart';
import 'package:flower_app/features/cart/data/models/cart_response_model.dart';
import 'package:flower_app/features/cart/data/models/update_cart_item_request.dart';
import 'package:flower_app/features/cart/data/repo_impl/cart_repo_impl.dart';
import 'package:flower_app/features/cart/domain/entities/cart_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'cart_repo_impl_test.mocks.dart';

@GenerateMocks([CartRemoteDataSource])
void main() {
  late MockCartRemoteDataSource mockRemoteDataSource;
  late CartRepoImpl repo;

  const cartResponse = CartResponseModel(
    success: true,
    message: 'Request completed successfully',
    data: CartDto(
      id: 'cart-1',
      customerId: 'customer-1',
      items: [
        CartItemDto(
          id: 'item-1',
          productId: 'product-1',
          productName: 'Fresh Flower Arrangement',
          unitPrice: 150,
          quantity: 2,
          lineSubtotal: 300,
          inStock: true,
          availableStock: 50,
        ),
      ],
      subtotal: 300,
      total: 300,
    ),
  );

  final dioException = DioException(requestOptions: RequestOptions(path: ''));

  setUp(() {
    mockRemoteDataSource = MockCartRemoteDataSource();
    repo = CartRepoImpl(mockRemoteDataSource);
  });

  group('getCart', () {
    test('returns SuccessResponse with the mapped entity', () async {
      // Arrange
      when(
        mockRemoteDataSource.getCart(),
      ).thenAnswer((_) async => cartResponse);

      // Act
      final result = await repo.getCart();

      // Assert
      expect(result, isA<SuccessResponse<CartEntity>>());
      final cart = (result as SuccessResponse<CartEntity>).data;
      expect(cart.id, 'cart-1');
      expect(cart.items.single.productName, 'Fresh Flower Arrangement');
      expect(cart.itemsCount, 2);
    });

    test('an envelope with a null cart reads as an empty cart, not a failure',
        () async {
      // Arrange
      when(
        mockRemoteDataSource.getCart(),
      ).thenAnswer((_) async => const CartResponseModel(success: true));

      // Act
      final result = await repo.getCart();

      // Assert
      expect(result, isA<SuccessResponse<CartEntity>>());
      expect((result as SuccessResponse<CartEntity>).data.isEmpty, isTrue);
    });

    test('returns ErrorResponse when the data source throws', () async {
      when(mockRemoteDataSource.getCart()).thenThrow(dioException);

      final result = await repo.getCart();

      expect(result, isA<ErrorResponse<CartEntity>>());
    });
  });

  group('addToCart', () {
    test('sends the product id and quantity it was given', () async {
      // Arrange
      when(
        mockRemoteDataSource.addToCart(any),
      ).thenAnswer((_) async => cartResponse);

      // Act
      final result = await repo.addToCart(productId: 'product-1', quantity: 3);

      // Assert
      final request =
          verify(mockRemoteDataSource.addToCart(captureAny)).captured.single
              as AddToCartItemRequest;
      expect(request.productId, 'product-1');
      expect(request.quantity, 3);
      expect(result, isA<SuccessResponse<CartEntity>>());
    });

    test('returns ErrorResponse when the data source throws', () async {
      when(mockRemoteDataSource.addToCart(any)).thenThrow(dioException);

      final result = await repo.addToCart(productId: 'product-1', quantity: 1);

      expect(result, isA<ErrorResponse<CartEntity>>());
      verifyNever(mockRemoteDataSource.getCart());
    });
  });

  group('updateCartItemQuantity', () {
    test('re-reads the cart, because PATCH answers with an empty 200',
        () async {
      // Arrange
      when(
        mockRemoteDataSource.updateCartItemQuantity(
          productId: anyNamed('productId'),
          request: anyNamed('request'),
        ),
      ).thenAnswer((_) async {});
      when(
        mockRemoteDataSource.getCart(),
      ).thenAnswer((_) async => cartResponse);

      // Act
      final result = await repo.updateCartItemQuantity(
        productId: 'product-1',
        quantity: 5,
      );

      // Assert
      final request = verify(
        mockRemoteDataSource.updateCartItemQuantity(
          productId: 'product-1',
          request: captureAnyNamed('request'),
        ),
      ).captured.single as UpdateCartItemRequest;
      expect(request.quantity, 5);

      verify(mockRemoteDataSource.getCart()).called(1);
      expect(result, isA<SuccessResponse<CartEntity>>());
    });

    test('does not re-read the cart when the update itself fails', () async {
      when(
        mockRemoteDataSource.updateCartItemQuantity(
          productId: anyNamed('productId'),
          request: anyNamed('request'),
        ),
      ).thenThrow(dioException);

      final result = await repo.updateCartItemQuantity(
        productId: 'product-1',
        quantity: 5,
      );

      expect(result, isA<ErrorResponse<CartEntity>>());
      verifyNever(mockRemoteDataSource.getCart());
    });

    test('surfaces a failure of the follow-up read', () async {
      when(
        mockRemoteDataSource.updateCartItemQuantity(
          productId: anyNamed('productId'),
          request: anyNamed('request'),
        ),
      ).thenAnswer((_) async {});
      when(mockRemoteDataSource.getCart()).thenThrow(dioException);

      final result = await repo.updateCartItemQuantity(
        productId: 'product-1',
        quantity: 5,
      );

      expect(result, isA<ErrorResponse<CartEntity>>());
    });
  });

  group('removeCartItem', () {
    test('removes by cart item id and maps the returned cart', () async {
      // Arrange
      when(
        mockRemoteDataSource.removeCartItem(any),
      ).thenAnswer((_) async => cartResponse);

      // Act
      final result = await repo.removeCartItem(cartItemId: 'item-1');

      // Assert
      verify(mockRemoteDataSource.removeCartItem('item-1')).called(1);
      expect(result, isA<SuccessResponse<CartEntity>>());
    });

    test('returns ErrorResponse when the data source throws', () async {
      when(mockRemoteDataSource.removeCartItem(any)).thenThrow(dioException);

      final result = await repo.removeCartItem(cartItemId: 'item-1');

      expect(result, isA<ErrorResponse<CartEntity>>());
    });
  });
}
