// lib/features/checkout/api/client/checkout_api_client.dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/models/checkout_details_response.dart';
import '../../data/models/estimated_delivery_response.dart';
import '../../data/models/place_order_request.dart';
import '../../data/models/place_order_response.dart';


part 'checkout_api_client.g.dart';

@RestApi()
abstract class CheckoutApiClient {
  factory CheckoutApiClient(Dio dio, {String baseUrl}) = _CheckoutApiClient;

  @GET('/checkout/details')
  Future<CheckoutDetailsResponse> getCheckoutDetails(
      @Query('cartId') String cartId,
      );

  @GET('/checkout/estimate-delivery')
  Future<EstimateDeliveryResponse> estimateDelivery(
      @Query('addressId') String addressId,
      @Query('cartId') String cartId,
      );

  @POST('/orders/place')
  Future<PlaceOrderResponse> placeOrder(
      @Body() PlaceOrderRequest request,
      );
}