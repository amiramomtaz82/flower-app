import '../../domain/entities/cod_payment_request_entity.dart';
import '../models/cod_payment_request.dart';

extension CodPaymentEntityMapper on CodPaymentRequestEntity {
  CodPaymentRequest toDto() {
    return CodPaymentRequest(
      orderId: orderId,
      amount: amount,
      currency: currency,
    );
  }
}