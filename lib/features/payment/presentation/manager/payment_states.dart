import 'package:equatable/equatable.dart';
import '../../../../config/resource/rsource.dart';
import '../../../checkout/domain/entities/card_payment_session_entity.dart';
import '../../domain/entities/cod_payment_entity.dart';
import '../../domain/entities/payment_status_entity.dart';

const Object _sentinel = Object();

class PaymentState extends Equatable {
  final Resource<CardPaymentSessionEntity> cardSessionResource;
  final Resource<CodPaymentEntity> codPaymentResource;
  final Resource<PaymentStatusEntity> paymentStatusResource;
  final Resource<CardPaymentSessionEntity> retrySessionResource;
  final String? verificationMessage;

  const PaymentState({
    required this.cardSessionResource,
    required this.codPaymentResource,
    required this.paymentStatusResource,
    required this.retrySessionResource,
    this.verificationMessage,
  });

  factory PaymentState.initial() => PaymentState(
    cardSessionResource: const Resource.initial(),
    codPaymentResource: const Resource.initial(),
    paymentStatusResource: const Resource.initial(),
    retrySessionResource: const Resource.initial(),
    verificationMessage: null,
  );

  PaymentState copyWith({
    Resource<CardPaymentSessionEntity>? cardSessionResource,
    Resource<CodPaymentEntity>? codPaymentResource,
    Resource<PaymentStatusEntity>? paymentStatusResource,
    Resource<CardPaymentSessionEntity>? retrySessionResource,
    Object? verificationMessage = _sentinel,
  }) {
    return PaymentState(
      cardSessionResource: cardSessionResource ?? this.cardSessionResource,
      codPaymentResource: codPaymentResource ?? this.codPaymentResource,
      paymentStatusResource: paymentStatusResource ?? this.paymentStatusResource,
      retrySessionResource: retrySessionResource ?? this.retrySessionResource,
      verificationMessage: identical(verificationMessage, _sentinel)
          ? this.verificationMessage
          : verificationMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    cardSessionResource,
    codPaymentResource,
    paymentStatusResource,
    retrySessionResource,
    verificationMessage,
  ];
}