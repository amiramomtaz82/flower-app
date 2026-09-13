import '../../models/add_to_cart_item_request.dart';
import '../../models/cart_response_model.dart';
import '../../models/update_cart_item_request.dart';

abstract interface class CartRemoteDataSource {
  Future<CartResponseModel> getCart();

  Future<CartResponseModel> addToCart(AddToCartItemRequest request);

  /// The backend answers this one with `200` and no body, so there is no cart
  /// to return — the repo re-reads the cart afterwards.
  Future<void> updateCartItemQuantity({
    required String productId,
    required UpdateCartItemRequest request,
  });

  Future<CartResponseModel> removeCartItem(String cartItemId);
}
