// lib/features/checkout/api/client/checkout_api_client.dart
import 'package:dio/dio.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_constants/endpoints.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/models/checkout_details_response.dart';
import '../../data/models/estimated_delivery_response.dart';
import '../../data/models/place_order_request.dart';
import '../../data/models/place_order_response.dart';


part 'checkout_api_client.g.dart';

@RestApi()
@lazySingleton
abstract class CheckoutApiClient {
  @factoryMethod
  factory CheckoutApiClient(Dio dio) = _CheckoutApiClient;

  @GET(Endpoints.checkoutDetails)
  Future<CheckoutDetailsResponse> getCheckoutDetails(
      @Query(AppStrings.cartId) String cartId,
      );

  @GET(Endpoints.estimateDelivery)
  Future<EstimateDeliveryResponse> estimateDelivery(
      @Query(AppStrings.addressId) String addressId,
      @Query(AppStrings.cartId) String cartId,
      );

  @POST(Endpoints.placeOrder)
  Future<PlaceOrderResponse> placeOrder(
      @Body() PlaceOrderRequest request,
      );
}