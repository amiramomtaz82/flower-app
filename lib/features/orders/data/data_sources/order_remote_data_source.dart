import 'package:flower_app/features/orders/data/models/orders_response_model.dart';

abstract interface class OrderRemoteDataSource {
  Future<OrdersResponseModel> getOrders({
    required int pageNumber,
    required int pageSize,
  });
}
