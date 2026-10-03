import 'package:equatable/equatable.dart';
import '../../domain/entities/card_checkout_session_request_entity.dart';
import '../../domain/entities/cod_payment_request_entity.dart';

sealed class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class CreateCardSessionEvent extends PaymentEvent {
  final CardCheckoutSessionRequestEntity request;
  const CreateCardSessionEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class CreateCodPaymentEvent extends PaymentEvent {
  final CodPaymentRequestEntity request;
  const CreateCodPaymentEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class StartPaymentVerificationEvent extends PaymentEvent {
  final String orderId;
  const StartPaymentVerificationEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class RetryPaymentEvent extends PaymentEvent {
  final String orderId;
  const RetryPaymentEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class ResetPaymentStateEvent extends PaymentEvent {
  const ResetPaymentStateEvent();
}