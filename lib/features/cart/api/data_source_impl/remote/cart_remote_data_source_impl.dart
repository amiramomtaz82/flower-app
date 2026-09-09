import 'package:injectable/injectable.dart';

import '../../../data/data_source/remote/cart_remote_data_source.dart';
import '../../../data/models/add_to_cart_item_request.dart';
import '../../../data/models/cart_response_model.dart';
import '../../../data/models/update_cart_item_request.dart';
import '../../client/cart_client.dart';

@Injectable(as: CartRemoteDataSource)
class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final CartClient _cartClient;

  CartRemoteDataSourceImpl(this._cartClient);

  @override
  Future<CartResponseModel> getCart() => _cartClient.getCart();

  @override
  Future<CartResponseModel> addToCart(AddToCartItemRequest request) =>
      _cartClient.addToCart(request);

  @override
  Future<void> updateCartItemQuantity({
    required String productId,
    required UpdateCartItemRequest request,
  }) => _cartClient.updateCartItemQuantity(productId, request);

  @override
  Future<CartResponseModel> removeCartItem(String cartItemId) =>
      _cartClient.removeCartItem(cartItemId);
}
