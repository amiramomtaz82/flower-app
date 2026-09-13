import '../../models/add_to_cart_item_request.dart';
import '../../models/cart_response_model.dart';
import '../../models/update_cart_item_request.dart';

abstract interface class CartRemoteDataSource {
  Future<CartResponseModel> getCart();

  Future<CartResponseModel> addToCart(AddToCartItemRequest request);

  Future<void> updateCartItemQuantity({
    required String productId,
    required UpdateCartItemRequest request,
  });

  Future<CartResponseModel> removeCartItem(String cartItemId);
}
