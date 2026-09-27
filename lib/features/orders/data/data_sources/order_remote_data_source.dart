import 'package:flower_app/features/orders/data/models/orders_response_model.dart';

import '../models/order_details_model.dart';
import '../models/order_tacking_response.dart';

abstract interface class OrderRemoteDataSource {
  Future<OrdersResponseModel> getOrders({
    required int pageNumber,
    required int pageSize,
  });
  Future<OrderTackingResponse> getLiveTracking(String orderId);
  Future<bool> confirmOrderDelivery(String orderId);
  Future<OrderDetailsModel> getOrderById(String orderId);
}
