import 'dart:async';
import 'package:flower_app/features/payment/presentation/manager/payment_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../../../../config/resource/rsource.dart';
import '../../../checkout/domain/entities/card_payment_session_entity.dart';
import '../../domain/entities/card_checkout_session_request_entity.dart';
import '../../domain/entities/cod_payment_entity.dart';
import '../../domain/entities/cod_payment_request_entity.dart';
import '../../domain/entities/payment_status_entity.dart';
import '../../domain/usecases/create_card_session_usecase.dart';
import '../../domain/usecases/create_cod_payment_usecase.dart';
import '../../domain/usecases/get_payment_status_usecase.dart';
import '../../domain/usecases/retry_payment_usecase.dart';
import 'payment_events.dart';


@injectable
class PaymentCubit extends Cubit<PaymentState> {
  final CreateCardSessionUseCase _createCardSessionUseCase;
  final CreateCodPaymentUseCase _createCodPaymentUseCase;
  final GetPaymentStatusUseCase _getPaymentStatusUseCase;
  final RetryPaymentUseCase _retryPaymentUseCase;

  PaymentCubit(
      this._createCardSessionUseCase,
      this._createCodPaymentUseCase,
      this._getPaymentStatusUseCase,
      this._retryPaymentUseCase,
      ) : super(PaymentState.initial());

  Future<void> doEvents(PaymentEvent event) async {
    switch (event) {
      case CreateCardSessionEvent():
        await _createCardSession(event.request);
      case CreateCodPaymentEvent():
        await _createCodPayment(event.request);
      case StartPaymentVerificationEvent():
        await _verifyPaymentStatus(event.orderId);
      case RetryPaymentEvent():
        await _retryPayment(event.orderId);
      case ResetPaymentStateEvent():
        emit(PaymentState.initial());
    }
  }

  Future<void> _createCardSession(CardCheckoutSessionRequestEntity request) async {
    emit(state.copyWith(cardSessionResource: const Resource.loading()));
    final result = await _createCardSessionUseCase(request);
    switch (result) {
      case SuccessResponse<CardPaymentSessionEntity>():
        emit(state.copyWith(cardSessionResource: Resource.success(result.data)));
      case ErrorResponse<CardPaymentSessionEntity>():
        emit(state.copyWith(cardSessionResource: Resource.error(result.errMessage)));
    }
  }

  Future<void> _createCodPayment(CodPaymentRequestEntity request) async {
    emit(state.copyWith(codPaymentResource: const Resource.loading()));
    final result = await _createCodPaymentUseCase(request);
    switch (result) {
      case SuccessResponse<CodPaymentEntity>():
        emit(state.copyWith(codPaymentResource: Resource.success(result.data)));
      case ErrorResponse<CodPaymentEntity>():
        emit(state.copyWith(codPaymentResource: Resource.error(result.errMessage)));
    }
  }

  /// Polls GET /payments/orders/{orderId}/status up to 4 times (every 2s)
  /// to give Paymob's server-to-server webhook time to arrive and validate.
  Future<void> _verifyPaymentStatus(String orderId) async {
    emit(state.copyWith(
      paymentStatusResource: const Resource.loading(),
      verificationMessage: 'Verifying payment with payment gateway...',
    ));

    int attempts = 0;
    const maxAttempts = 6;

    while (attempts < maxAttempts) {
      attempts++;
      final result = await _getPaymentStatusUseCase(orderId);

      switch (result) {
        case SuccessResponse<PaymentStatusEntity>():
          final payment = result.data;
          if (payment.isPaid) {
            emit(state.copyWith(
              paymentStatusResource: Resource.success(payment),
              verificationMessage: null,
            ));
            return;
          } else if (payment.isFailed) {
            emit(state.copyWith(
              paymentStatusResource: Resource.error('Payment was declined or cancelled.'),
              verificationMessage: null,
            ));
            return;
          }
        case ErrorResponse<PaymentStatusEntity>():
          if (attempts == maxAttempts) {
            emit(state.copyWith(
              paymentStatusResource: Resource.error(result.errMessage),
              verificationMessage: null,
            ));
            return;
          }
      }

      if (attempts < maxAttempts) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    emit(state.copyWith(
      paymentStatusResource: const Resource.error('Payment confirmation timed out. Please retry.'),
      verificationMessage: null,
    ));
  }

  Future<void> _retryPayment(String orderId) async {
    emit(state.copyWith(
      paymentStatusResource: const Resource.initial(),
      retrySessionResource: const Resource.loading(),
    ));
    final result = await _retryPaymentUseCase(orderId);
    switch (result) {
      case SuccessResponse<CardPaymentSessionEntity>():
        emit(state.copyWith(retrySessionResource: Resource.success(result.data)));
      case ErrorResponse<CardPaymentSessionEntity>():
        emit(state.copyWith(retrySessionResource: Resource.error(result.errMessage)));
    }
  }
}