import 'package:dio/dio.dart';
import 'package:flower_app/core/app_constants/endpoints.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/models/add_to_cart_item_request.dart';
import '../../data/models/cart_response_model.dart';
import '../../data/models/update_cart_item_request.dart';

part 'cart_client.g.dart';

@singleton
@RestApi()
abstract class CartClient {
  @factoryMethod
  factory CartClient(Dio dio) = _CartClient;

  @GET(Endpoints.cart)
  Future<CartResponseModel> getCart();

  @POST(Endpoints.cartItems)
  Future<CartResponseModel> addToCart(@Body() AddToCartItemRequest request);

  @PATCH(Endpoints.updateCartItemQuantity)
  Future<void> updateCartItemQuantity(
    @Path('productId') String productId,
    @Body() UpdateCartItemRequest request,
  );

  @DELETE(Endpoints.cartItemById)
  Future<CartResponseModel> removeCartItem(@Path('id') String cartItemId);
}
