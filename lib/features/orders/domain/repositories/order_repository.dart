import 'package:flower_app/features/orders/domain/entities/order_entity.dart';
import 'package:flower_app/core/network/base_response.dart';
import 'package:flower_app/core/pagination/paginated_response.dart';

abstract interface class OrderRepository {
  Future<BaseResponse<PaginatedResponse<OrderEntity>>> getOrders({
    required int pageNumber,
    required int pageSize,
  });
}
