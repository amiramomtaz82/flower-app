import 'package:flower_app/config/base_response/base_response.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/cart_entity.dart';
import '../../domain/repo/cart_repo.dart';
import '../data_source/remote/cart_remote_data_source.dart';
import '../models/add_to_cart_item_request.dart';
import '../models/cart_response_model.dart';
import '../models/update_cart_item_request.dart';

@Injectable(as: CartRepo)
class CartRepoImpl implements CartRepo {
  final CartRemoteDataSource _cartRemoteDataSource;

  CartRepoImpl(this._cartRemoteDataSource);

  @override
  Future<BaseResponse<CartEntity>> getCart() async {
    try {
      final response = await _cartRemoteDataSource.getCart();
      return SuccessResponse(_toEntity(response));
    } catch (e) {
      return ErrorResponse(error: e);
    }
  }

  @override
  Future<BaseResponse<CartEntity>> addToCart({
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await _cartRemoteDataSource.addToCart(
        AddToCartItemRequest(productId: productId, quantity: quantity),
      );
      return SuccessResponse(_toEntity(response));
    } catch (e) {
      return ErrorResponse(error: e);
    }
  }

  @override
  Future<BaseResponse<CartEntity>> updateCartItemQuantity({
    required String productId,
    required int quantity,
  }) async {
    try {
      await _cartRemoteDataSource.updateCartItemQuantity(
        productId: productId,
        request: UpdateCartItemRequest(quantity: quantity),
      );
    } catch (e) {
      return ErrorResponse(error: e);
    }

    // PATCH answers with an empty `200`, so the updated cart has to be re-read.
    return getCart();
  }

  @override
  Future<BaseResponse<CartEntity>> removeCartItem({
    required String cartItemId,
  }) async {
    try {
      final response = await _cartRemoteDataSource.removeCartItem(cartItemId);
      return SuccessResponse(_toEntity(response));
    } catch (e) {
      return ErrorResponse(error: e);
    }
  }

  /// The envelope carries a null `data` when the cart is empty, which is a
  /// successful read of an empty cart rather than a failure.
  CartEntity _toEntity(CartResponseModel response) =>
      response.data?.toEntity() ?? const CartEntity();
}
