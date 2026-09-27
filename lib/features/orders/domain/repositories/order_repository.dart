import 'package:flower_app/features/orders/domain/entities/order_entity.dart';
import 'package:flower_app/core/network/base_response.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';

import '../entities/order_tracking_entity.dart';
import '../oredr_details_entity.dart';

abstract interface class OrderRepository {
  Future<BaseResponse<PaginatedResponse<OrderEntity>>> getOrders({
    required int pageNumber,
    required int pageSize,
  });
  Future<BaseResponse<OrderTrackingEntity>> getLiveTracking(String orderId);
  Future<BaseResponse<bool>> confirmOrderDelivery(String orderId);
  Future<BaseResponse<OrderDetailsEntity>> getOrderById(String orderId);
}
