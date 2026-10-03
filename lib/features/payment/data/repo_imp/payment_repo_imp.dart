import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../../../checkout/data/models/place_order_response.dart';
import '../../../checkout/domain/entities/card_payment_session_entity.dart';
import '../../domain/entities/card_checkout_session_request_entity.dart';

import '../../domain/entities/cod_payment_entity.dart';
import '../../domain/entities/cod_payment_request_entity.dart';
import '../../domain/entities/payment_status_entity.dart';
import '../../domain/repo/payment_repo.dart';
import '../data_source/payment_remote_data_source.dart';

import '../models/cod_payment_response.dart';
import '../models/payment_status_model.dart';


@LazySingleton(as: PaymentRepository)
class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _remoteDataSource;

  PaymentRepositoryImpl(this._remoteDataSource);

  @override
  Future<BaseResponse<CardPaymentSessionEntity>> createCardSession(
      CardCheckoutSessionRequestEntity request,
      ) async {
    // 1. Entity -> DTO via mapper extension
    final response = await _remoteDataSource.createCardCheckoutSession(request.toDto());

    switch (response) {
      case SuccessResponse<PlaceOrderResponse>():
      // 2. DTO -> Entity via toEntity()
        final sessionEntity = response.data.data?.toEntity();
        if (sessionEntity == null) {
          return ErrorResponse(errMessage: 'No payment session returned.');
        }
        return SuccessResponse<CardPaymentSessionEntity>(sessionEntity);

      case ErrorResponse<PlaceOrderResponse>():
        return ErrorResponse<CardPaymentSessionEntity>(
          error: response.error,
          errMessage: response.errMessage,
        );
    }
  }

  @override
  Future<BaseResponse<CodPaymentEntity>> createCodPayment(
      CodPaymentRequestEntity request,
      ) async {
    // 1. Entity -> DTO via mapper extension
    final response = await _remoteDataSource.createCodPayment(request.toDto());

    switch (response) {
      case SuccessResponse<CodPaymentResponse>():
      // 2. DTO -> Entity via toEntity()
        final codEntity = response.data.data?.toEntity();
        if (codEntity == null) {
          return ErrorResponse(errMessage: 'COD payment failed.');
        }
        return SuccessResponse<CodPaymentEntity>(codEntity);

      case ErrorResponse<CodPaymentResponse>():
        return ErrorResponse<CodPaymentEntity>(
          error: response.error,
          errMessage: response.errMessage,
        );
    }
  }

  @override
  Future<BaseResponse<PaymentStatusEntity>> getPaymentStatus(String orderId) async {
    final response = await _remoteDataSource.getPaymentStatus(orderId);

    switch (response) {
      case SuccessResponse<PaymentStatusResponse>():
        final statusEntity = response.data.data?.toEntity();
        if (statusEntity == null) {
          return ErrorResponse(errMessage: 'Unable to retrieve payment status.');
        }
        return SuccessResponse<PaymentStatusEntity>(statusEntity);

      case ErrorResponse<PaymentStatusResponse>():
        return ErrorResponse<PaymentStatusEntity>(
          error: response.error,
          errMessage: response.errMessage,
        );
    }
  }

  @override
  Future<BaseResponse<CardPaymentSessionEntity>> retryPayment(String orderId) async {
    final response = await _remoteDataSource.retryPayment(orderId);

    switch (response) {
      case SuccessResponse<PlaceOrderResponse>():
        final sessionEntity = response.data.data?.toEntity();
        if (sessionEntity == null) {
          return ErrorResponse(errMessage: 'Failed to generate retry session.');
        }
        return SuccessResponse<CardPaymentSessionEntity>(sessionEntity);

      case ErrorResponse<PlaceOrderResponse>():
        return ErrorResponse<CardPaymentSessionEntity>(
          error: response.error,
          errMessage: response.errMessage,
        );
    }
  }
}