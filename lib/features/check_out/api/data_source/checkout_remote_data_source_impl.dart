// lib/features/checkout/data/data_sources/checkout_remote_data_source.dart
import '../../../../config/base_response/base_response.dart';
import '../../data/models/checkout_details_response.dart';
import '../../data/models/estimated_delivery_response.dart';
import '../../data/models/place_order_request.dart';
import '../../data/models/place_order_response.dart';

abstract class CheckoutRemoteDataSource {
  Future<BaseResponse<CheckoutDetailsResponse>> getCheckoutDetails(String cartId);
  Future<BaseResponse<EstimateDeliveryResponse>> estimateDelivery(String addressId, String cartId);
  Future<BaseResponse<PlaceOrderResponse>> placeOrder(PlaceOrderRequest request);
}