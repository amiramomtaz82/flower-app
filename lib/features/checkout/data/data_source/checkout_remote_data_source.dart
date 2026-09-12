// lib/features/checkout/data/data_sources/checkout_remote_data_source_imp.dart
import '../../../../config/base_response/base_response.dart';
import '../models/checkout_details_response.dart';
import '../models/estimated_delivery_response.dart';
import '../models/place_order_request.dart';
import '../models/place_order_response.dart';

abstract interface class CheckoutRemoteDataSource {
  Future<BaseResponse<CheckoutDetailsResponse>> getCheckoutDetails(String cartId);
  Future<BaseResponse<EstimateDeliveryResponse>> estimateDelivery(String addressId, String cartId);
  Future<BaseResponse<PlaceOrderResponse>> placeOrder(PlaceOrderRequest request);
}