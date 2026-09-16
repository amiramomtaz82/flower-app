import 'package:flower_app/features/orders/domain/entities/order_entity.dart';
import 'package:flower_app/features/orders/api/client/order_api_client.dart';
import 'package:injectable/injectable.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderEntity>> getOrders();
}

@Injectable(as: OrderRemoteDataSource)
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  OrderRemoteDataSourceImpl(this._apiClient);
  
  final OrderApiClient _apiClient;

  @override
  Future<List<OrderEntity>> getOrders() async {
    final response = await _apiClient.getOrders(1, 10);
    return response.orders;
  }
}
