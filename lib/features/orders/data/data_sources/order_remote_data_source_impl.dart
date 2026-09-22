import 'package:flower_app/features/orders/api/client/order_api_client.dart';
import 'package:flower_app/features/orders/data/data_sources/order_remote_data_source.dart';
import 'package:flower_app/features/orders/data/models/orders_response_model.dart';
import 'package:injectable/injectable.dart';

import '../models/current_location_dto.dart';
import '../models/driver_dto.dart';
import '../models/order_tacking_response.dart';
import '../models/order_traching_dto.dart';
import '../models/user_address_dto.dart';

@Injectable(as: OrderRemoteDataSource)
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  OrderRemoteDataSourceImpl(this._apiClient);
  
  final OrderApiClient _apiClient;
  final bool _isTrackingMockMode = true;

  @override
  Future<OrdersResponseModel> getOrders({
    required int pageNumber,
    required int pageSize,
  }) async {
    return _apiClient.getOrders(pageNumber, pageSize);
  }


  @override
  Future<OrderTackingResponse> getLiveTracking(String orderId) async {
    if (_isTrackingMockMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      return OrderTackingResponse(
        isSuccess: true,
        statusCode: 'Success',
        message: 'Success',
        data: OrderTrackingDto(
          orderId: orderId,
          status: 'OutForDelivery',
          isLive: true,
          awaitingCustomerConfirmation: false, // Set to true to test Screen 3 (dual buttons)
          estimatedDeliveryAt: DateTime.now().add(const Duration(minutes: 25)).toIso8601String(),
          driver: DriverDto(
            driverId: '01a03975-5bd9-7db4-8e83-599af35ee26c',
            name: 'Mohamed',
            phone: '+201012345678',
            photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
          ),
          currentLocation: CurrentLocation(
            lat: 30.0488,
            lng: 31.2330,
            recordedAt: DateTime.now().toIso8601String(),
            isStale: false,
          ),
          userAddress: UserAddress(
            lat: 30.0444,
            lng: 31.2357,
            addressLine: '123 Tahrir Square, Downtown',
          ),
        ),
      );
    }
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
}
