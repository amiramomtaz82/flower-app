
import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';

import '../../data/data_source/checkout_remote_data_source.dart';
import '../api_client/checkout_api_client.dart';

import '../../data/models/checkout_details_response.dart';
import '../../data/models/estimated_delivery_response.dart';
import '../../data/models/place_order_request.dart';
import '../../data/models/place_order_response.dart';


@LazySingleton(as: CheckoutRemoteDataSource)
class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final CheckoutApiClient _apiClient;

  // Toggle this boolean to switch between local mock data and the live API
  final bool _isMockMode = true;

  CheckoutRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<CheckoutDetailsResponse>> getCheckoutDetails(String cartId) async {
    if (_isMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));

      final mockData = CheckoutDetailsResponse(
        isSuccess: true,
        message: 'Success',
        statusCode: 'Success',
        data: CheckoutDetailsDto(
          cartId: cartId,
          addressId: 'addr-mock-001',
          isServiceable: true,
          subtotal: 1095.0,
          deliveryFee: 10.0,
          total: 1105.0,
          estimatedDeliveryAt: '2026-09-02T14:00:00Z',
          paymentMethods: [
            PaymentMethodOption(method: 'COD'),
            PaymentMethodOption(
              method: 'Card',
              gateways: ['Paymob', 'Stripe'],
            ),
          ],
          isGift: false,
        ),
      );

      return SuccessResponse<CheckoutDetailsResponse>(mockData);
    }

    try {
      final response = await _apiClient.getCheckoutDetails(cartId);
      return SuccessResponse<CheckoutDetailsResponse>(response);
    } catch (e) {
      return ErrorResponse<CheckoutDetailsResponse>(error: e);
    }
  }

  @override
  Future<BaseResponse<EstimateDeliveryResponse>> estimateDelivery(
      String addressId,
      String cartId,
      ) async {
    if (_isMockMode) {
      await Future.delayed(const Duration(milliseconds: 350));

      final mockData = EstimateDeliveryResponse(
        isSuccess: true,
        message: 'Success',
        statusCode: 'Success',
        data: EstimateDeliveryDto(
          addressId: addressId,
          isServiceable: true,
          deliveryFee: 15.0,
          estimatedDeliveryAt: '2026-09-02T15:30:00Z',
        ),
      );

      return SuccessResponse<EstimateDeliveryResponse>(mockData);
    }

    try {
      final response = await _apiClient.estimateDelivery(addressId, cartId);
      return SuccessResponse<EstimateDeliveryResponse>(response);
    } catch (e) {
      return ErrorResponse<EstimateDeliveryResponse>(error: e);
    }
  }

  @override
  Future<BaseResponse<PlaceOrderResponse>> placeOrder
      (PlaceOrderRequest request) async {
    if (_isMockMode) {
      await Future.delayed(const Duration(milliseconds: 800));

      // COD returns null data; Card returns the gateway session details
      if (request.paymentMethod == 'COD') {
        final mockCodData = PlaceOrderResponse(
          isSuccess: true,
          message: 'Order Placed Successfully',
          statusCode: 'Created',
          data: null,
        );
        return SuccessResponse<PlaceOrderResponse>(mockCodData);
      } else {
        final mockCardData = PlaceOrderResponse(
          isSuccess: true,
          message: 'Payment Session Created',
          statusCode: 'Created',
          data: CardPaymentSessionDto(
            orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
            status: 'PendingPayment',
            gateway: request.paymentGateway ?? 'Paymob',
            sessionId: 'sess-${DateTime.now().millisecondsSinceEpoch}',
            sessionUrl: 'https://httpstat.us/200', // Mock external payment page
            successUrl: 'flowery://payment/success',
            cancelUrl: 'flowery://payment/cancel',
            expiresAt: DateTime.now().add(const Duration(minutes: 30)).toIso8601String(),
            amount: 1105.0,
            currency: 'EGP',
            estimatedDeliveryAt: '2026-09-02T15:30:00Z',
          ),
        );
        return SuccessResponse<PlaceOrderResponse>(mockCardData);
      }
    }

    try {
      final response = await _apiClient.placeOrder(request);
      return SuccessResponse<PlaceOrderResponse>(response);
    } catch (e) {
      return ErrorResponse<PlaceOrderResponse>(error: e);
    }
  }
}