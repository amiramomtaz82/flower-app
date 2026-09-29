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
          status: 'preparing',
          isLive: true,
          awaitingCustomerConfirmation: true, // Set to true to test Screen 3 (dual buttons)
          estimatedDeliveryAt: DateTime.now().add(const Duration(minutes: 25)).toIso8601String(),
          driver: DriverDto(
            driverId: '01a03975-5bd9-7db4-8e83-599af35ee26c',
            name: 'Mohamed',
            phone: '+201012345678',
            photoUrl: "",
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

  @override
  Future<OrderDetailsModel> getOrderById(String orderId) async {
    if (_isTrackingMockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return const OrderDetailsModel(
        orderId: '123456',
        customerName: 'Nour',
        addressTitle: 'Home',
        addressDetail: '269VP+Q2 - Sheikh Zayed',
        paymentMethod: 'Pay with cash',
        currency: 'EGP',
        subTotal: 1000,
        deliveryFee: 105,
        total: 1105,
        items: [
          OrderItemModel(
            id: 'item_1',
            productName: 'Red roses',
            description: '18 Pink Rose Bouquet',
            price: 600,
            quantity: 1,
          ),
          OrderItemModel(
            id: 'item_2',
            productName: 'Red roses',
            description: '18 Pink Rose Bouquet',
            price: 600,
            quantity: 1,
          ),
          OrderItemModel(
            id: 'item_3',
            productName: 'Red roses',
            description: '18 Pink Rose Bouquet',
            price: 600,
            quantity: 1,
          ),
        ],
      );
    }
    return _apiClient.getOrderById(orderId);
  }
}
