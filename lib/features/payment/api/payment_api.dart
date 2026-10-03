import 'package:dio/dio.dart';
import 'package:flower_app/core/app_constants/endpoints.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../checkout/data/models/place_order_response.dart';
import '../data/models/card_checkout_session_request.dart';
import '../data/models/cod_payment_request.dart';
import '../data/models/cod_payment_response.dart';
import '../data/models/payment_status_model.dart';



part 'payment_api.g.dart';

@RestApi()
@lazySingleton
abstract class PaymentApiClient {
  @factoryMethod
  factory PaymentApiClient(Dio dio) = _PaymentApiClient;

  // Endpoint 1: Create Card Checkout Session
  @POST(Endpoints.createCardCheckoutSession)
  Future<PlaceOrderResponse> createCardCheckoutSession(
      @Body() CardCheckoutSessionRequest request,
      );

  // Endpoint 2: Create Cash on Delivery (COD) Payment
  @POST(Endpoints.createCodPayment)
  Future<CodPaymentResponse> createCodPayment(
      @Body() CodPaymentRequest request,
      );

  // Endpoint 3: Get Payment Status by Order ID
  @GET(Endpoints.paymentStatusByOrderId)
  Future<PaymentStatusResponse> getPaymentStatusByOrderId(
      @Path('orderId') String orderId,
      );

  // Endpoint 4: Retry Payment
  @POST(Endpoints.retryPayment)
  Future<PlaceOrderResponse> retryPayment(
      @Path('orderId') String orderId,
      );
}