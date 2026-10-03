import '../../../../config/base_response/base_response.dart';
import '../../../checkout/data/models/place_order_response.dart';
import '../models/card_checkout_session_request.dart';
import '../models/cod_payment_request.dart';
import '../models/cod_payment_response.dart';
import '../models/payment_status_model.dart';


abstract class PaymentRemoteDataSource {
  Future<BaseResponse<PlaceOrderResponse>> createCardCheckoutSession(CardCheckoutSessionRequest request);
  Future<BaseResponse<CodPaymentResponse>> createCodPayment(CodPaymentRequest request);
  Future<BaseResponse<PaymentStatusResponse>> getPaymentStatus(String orderId);
  Future<BaseResponse<PlaceOrderResponse>> retryPayment(String orderId);
}