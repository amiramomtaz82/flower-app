import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../../../checkout/data/models/place_order_response.dart';
import '../../api/payment_api.dart';
import '../../data/data_source/payment_remote_data_source.dart';
import '../../data/models/card_checkout_session_request.dart';
import '../../data/models/cod_payment_request.dart';
import '../../data/models/cod_payment_response.dart';

import '../models/payment_status_model.dart';

@LazySingleton(as: PaymentRemoteDataSource)
class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final PaymentApiClient _apiClient;

  PaymentRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<PlaceOrderResponse>> createCardCheckoutSession(CardCheckoutSessionRequest request) async {
    try {
      final response = await _apiClient.createCardCheckoutSession(request);
      return SuccessResponse(response);
    } catch (e) {
      return ErrorResponse(error: e);
    }
  }

  @override
  Future<BaseResponse<CodPaymentResponse>> createCodPayment(CodPaymentRequest request) async {
    try {
      final response = await _apiClient.createCodPayment(request);
      return SuccessResponse(response);
    } catch (e) {
      return ErrorResponse(error: e);
    }
  }

  @override
  Future<BaseResponse<PaymentStatusResponse>> getPaymentStatus(String orderId) async {
    try {
      final response = await _apiClient.getPaymentStatusByOrderId(orderId);
      return SuccessResponse(response);
    } catch (e) {
      return ErrorResponse(error: e);
    }
  }

  @override
  Future<BaseResponse<PlaceOrderResponse>> retryPayment(String orderId) async {
    try {
      final response = await _apiClient.retryPayment(orderId);
      return SuccessResponse(response);
    } catch (e) {
      return ErrorResponse(error: e);
    }
  }
}