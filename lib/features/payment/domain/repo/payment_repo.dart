import '../../../../config/base_response/base_response.dart';
import '../../../checkout/domain/entities/card_payment_session_entity.dart';
import '../entities/card_checkout_session_request_entity.dart';

import '../entities/cod_payment_entity.dart';
import '../entities/cod_payment_request_entity.dart';
import '../entities/payment_status_entity.dart';

abstract  interface class PaymentRepository {
  /// Endpoint 1: Accepts Request Entity, Returns CardPaymentSessionEntity
  Future<BaseResponse<CardPaymentSessionEntity>> createCardSession(CardCheckoutSessionRequestEntity request);

  /// Endpoint 2: Accepts Request Entity, Returns CodPaymentEntity
  Future<BaseResponse<CodPaymentEntity>> createCodPayment(CodPaymentRequestEntity request);

  /// Endpoint 3: Returns PaymentStatusEntity
  Future<BaseResponse<PaymentStatusEntity>> getPaymentStatus(String orderId);

  /// Endpoint 4: Returns CardPaymentSessionEntity
  Future<BaseResponse<CardPaymentSessionEntity>> retryPayment(String orderId);
}