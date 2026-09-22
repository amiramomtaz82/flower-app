import 'package:dio/dio.dart';
import 'package:flower_app/core/app_constants/endpoints.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/models/orders_response_model.dart';
import '../../data/models/order_model.dart';

part 'order_api_client.g.dart';

@singleton
@RestApi()
abstract class OrderApiClient {
  @factoryMethod
  factory OrderApiClient(Dio dio) = _OrderApiClient;

  @GET(Endpoints.orders)
  Future<OrdersResponseModel> getOrders(
    @Query(QueryParams.pageNumber) int pageNumber,
    @Query(QueryParams.pageSize) int pageSize,
  );

  @GET(Endpoints.orderById)
  Future<OrderModel> getOrderById(
    @Path(QueryParams.orderId) String orderId,
  );
}
