

import '../models/card_checkout_session_request.dart';
import '../../domain/entities/card_checkout_session_request_entity.dart';

extension CardCheckoutSessionEntityMapper on CardCheckoutSessionRequestEntity {
  CardCheckoutSessionRequest toDto() {
    return CardCheckoutSessionRequest(
      orderId: orderId,
      amount: amount,
      currency: currency,
      customerEmail: customerEmail,
      customerFirstName: customerFirstName,
      customerLastName: customerLastName,
      customerPhone: customerPhone,
    );
  }
}