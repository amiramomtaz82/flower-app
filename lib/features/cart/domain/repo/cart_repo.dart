import 'package:flower_app/config/base_response/base_response.dart';

import '../entities/cart_entity.dart';

abstract interface class CartRepo {
  Future<BaseResponse<CartEntity>> getCart();

  Future<BaseResponse<CartEntity>> addToCart({
    required String productId,
    required int quantity,
  });

  /// Keyed by `productId`, not by cart item id — that is what the backend's
  /// PATCH route takes. Passing `0` removes the line.
  Future<BaseResponse<CartEntity>> updateCartItemQuantity({
    required String productId,
    required int quantity,
  });

  /// Keyed by the cart item id, unlike [updateCartItemQuantity].
  Future<BaseResponse<CartEntity>> removeCartItem({
    required String cartItemId,
  });
}
