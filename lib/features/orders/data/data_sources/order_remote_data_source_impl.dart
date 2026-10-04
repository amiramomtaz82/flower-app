import 'package:flower_app/features/orders/api/client/order_api_client.dart';
import 'package:flower_app/features/orders/data/data_sources/order_remote_data_source.dart';
import 'package:flower_app/features/orders/data/models/orders_response_model.dart';
import 'package:injectable/injectable.dart';

import '../models/current_location_dto.dart';
import '../models/driver_dto.dart';
import '../models/order_details_model.dart';
import '../models/order_item_model.dart';
import '../models/order_tacking_response.dart';
import '../models/order_traching_dto.dart';
import '../models/user_address_dto.dart';

@Injectable(as: OrderRemoteDataSource)
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  OrderRemoteDataSourceImpl(this._apiClient);
  
  final OrderApiClient _apiClient;
  final bool _isTrackingMockMode = false;

  @override
  Future<OrdersResponseModel> getOrders({
    required int pageNumber,
    required int pageSize,
  }) async {
    return _apiClient.getOrders(pageNumber, pageSize);
  }


  @override
  Future<OrderTackingResponse> getLiveTracking(String orderId) async {

    return _apiClient.getLiveTracking(orderId);
  }
  @override
  Future<bool> confirmOrderDelivery(String orderId) async {
    if (_isTrackingMockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    }
    await _apiClient.confirmOrderDelivery(orderId);
    return true;
  }

  @override
  Future<OrderDetailsModel> getOrderById(String orderId) async {

    return _apiClient.getOrderById(orderId);
  }
}
