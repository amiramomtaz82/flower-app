import 'package:flower_app/features/orders/api/client/order_api_client.dart';
import 'package:flower_app/features/orders/data/data_sources/order_remote_data_source.dart';
import 'package:flower_app/features/orders/data/models/orders_response_model.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: OrderRemoteDataSource)
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  OrderRemoteDataSourceImpl(this._apiClient);
  
  final OrderApiClient _apiClient;

  @override
  Future<OrdersResponseModel> getOrders({
    required int pageNumber,
    required int pageSize,
  }) async {
    return _apiClient.getOrders(pageNumber, pageSize);
  }
}
