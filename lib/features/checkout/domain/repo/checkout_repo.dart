// lib/features/checkout/domain/repositories/checkout_repository.dart
import '../../../../config/base_response/base_response.dart';
import '../entities/checkout_details_entity.dart';
import '../entities/estimated_delivery_entity.dart';
import '../entities/oder_placment_entity.dart';
import '../entities/place_order_request_entity.dart';


abstract interface class CheckoutRepository {
  Future<BaseResponse<CheckoutDetailsEntity>> getCheckoutDetails(String cartId);
  Future<BaseResponse<EstimateDeliveryEntity>> estimateDelivery(String addressId, String cartId);
  Future<BaseResponse<OrderPlacementEntity>> placeOrder(PlaceOrderRequestEntity order);
}