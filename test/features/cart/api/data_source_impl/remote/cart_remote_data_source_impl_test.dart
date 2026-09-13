import 'package:flower_app/features/cart/api/client/cart_client.dart';
import 'package:flower_app/features/cart/api/data_source_impl/remote/cart_remote_data_source_impl.dart';
import 'package:flower_app/features/cart/data/models/add_to_cart_item_request.dart';
import 'package:flower_app/features/cart/data/models/cart_dto.dart';
import 'package:flower_app/features/cart/data/models/cart_item_dto.dart';
import 'package:flower_app/features/cart/data/models/cart_response_model.dart';
import 'package:flower_app/features/cart/data/models/update_cart_item_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'cart_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([CartClient])
void main() {
  late CartRemoteDataSourceImpl cartRemoteDataSourceImpl;
  late MockCartClient mockCartClient;

  const fakeResponse = CartResponseModel(
    success: true,
    message: 'Request completed successfully',
    data: CartDto(
      id: 'cart-1',
      items: [
        CartItemDto(id: 'item-1', productId: 'product-1', quantity: 2),
      ],
      subtotal: 300,
      total: 300,
    ),
  );

  setUp(() {
    mockCartClient = MockCartClient();
    cartRemoteDataSourceImpl = CartRemoteDataSourceImpl(mockCartClient);
  });

  group('getCart', () {
    test('returns the client response untouched', () async {
      // Arrange
      when(mockCartClient.getCart()).thenAnswer((_) async => fakeResponse);

      // Act
      final result = await cartRemoteDataSourceImpl.getCart();

      // Assert
      expect(result, same(fakeResponse));
      verify(mockCartClient.getCart()).called(1);
    });
  });

  group('addToCart', () {
    test('passes the request through and returns the response', () async {
      // Arrange
      when(
        mockCartClient.addToCart(captureAny),
      ).thenAnswer((_) async => fakeResponse);

      // Act
      final result = await cartRemoteDataSourceImpl.addToCart(
        const AddToCartItemRequest(productId: 'product-1', quantity: 3),
      );

      // Assert
      expect(result, same(fakeResponse));
      final requestSent = verify(
        mockCartClient.addToCart(captureAny),
      ).captured.single;
      expect(requestSent.productId, 'product-1');
      expect(requestSent.quantity, 3);
    });
  });

  group('updateCartItemQuantity', () {
    test('sends the product id as a path argument, not the item id', () async {
      // Arrange
      when(
        mockCartClient.updateCartItemQuantity(any, any),
      ).thenAnswer((_) async {});

      // Act
      await cartRemoteDataSourceImpl.updateCartItemQuantity(
        productId: 'product-1',
        request: const UpdateCartItemRequest(quantity: 5),
      );

      // Assert
      final arguments = verify(
        mockCartClient.updateCartItemQuantity(captureAny, captureAny),
      ).captured;
      expect(arguments.first, 'product-1');
      expect((arguments.last as UpdateCartItemRequest).quantity, 5);
    });
  });

  group('removeCartItem', () {
    test('sends the cart item id and returns the response', () async {
      // Arrange
      when(
        mockCartClient.removeCartItem(any),
      ).thenAnswer((_) async => fakeResponse);

      // Act
      final result = await cartRemoteDataSourceImpl.removeCartItem('item-1');

      // Assert
      expect(result, same(fakeResponse));
      verify(mockCartClient.removeCartItem('item-1')).called(1);
    });
  });
}
