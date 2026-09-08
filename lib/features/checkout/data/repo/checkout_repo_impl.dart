// lib/features/checkout/data/repositories/checkout_repository_impl.dart
import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../data_source/checkout_remote_data_source.dart';
import '../../domain/entities/checkout_details_entity.dart';
import '../../domain/entities/estimated_delivery_entity.dart';

import '../../domain/entities/oder_placment_entity.dart';
import '../../domain/entities/place_order_request_entity.dart';

import '../../domain/repo/checkout_repo.dart';
import '../models/checkout_details_response.dart';

import '../models/estimated_delivery_response.dart';
import '../models/place_order_request.dart';
import '../models/place_order_response.dart';

@Injectable(as: CheckoutRepository)
class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource _remoteDataSource;

  CheckoutRepositoryImpl(this._remoteDataSource);

  @override
  Future<BaseResponse<CheckoutDetailsEntity>> getCheckoutDetails(String cartId) async {
    final response = await _remoteDataSource.getCheckoutDetails(cartId);

    switch (response) {
      case SuccessResponse<CheckoutDetailsResponse>():
        return SuccessResponse<CheckoutDetailsEntity>(
          response.data.data!.toEntity(),
        );

      case ErrorResponse<CheckoutDetailsResponse>():
        return ErrorResponse<CheckoutDetailsEntity>(
          error: response.error,
        );
    }
  }

  @override
  Future<BaseResponse<EstimateDeliveryEntity>> estimateDelivery(
      String addressId,
      String cartId,
      ) async {
    final response = await _remoteDataSource.estimateDelivery(addressId, cartId);

    switch (response) {
      case SuccessResponse<EstimateDeliveryResponse>():
        return SuccessResponse<EstimateDeliveryEntity>(
          response.data.data!.toEntity(),
        );

      case ErrorResponse<EstimateDeliveryResponse>():
        return ErrorResponse<EstimateDeliveryEntity>(
          error: response.error,
        );
    }
  }

  @override
  Future<BaseResponse<OrderPlacementEntity>> placeOrder(PlaceOrderRequestEntity order) async {
    final request = PlaceOrderRequest(
      cartId: order.cartId,
      addressId: order.addressId,
      isGift: order.isGift,
      giftRecipient: order.isGift && order.giftRecipient != null
          ? GiftRecipientRequest(
        recipientName: order.giftRecipient!.name,
        recipientPhone: order.giftRecipient!.phone,
      )
          : null,
      paymentMethod: order.paymentMethod,
      paymentGateway: order.paymentGateway,
    );

    final response = await _remoteDataSource.placeOrder(request);

    switch (response) {
      case SuccessResponse<PlaceOrderResponse>():
        final sessionData = response.data.data;
        final isCredit = order.paymentMethod.toLowerCase() == 'card' ||
            order.paymentMethod.toLowerCase() == 'credit';

        if (isCredit) {
          final sessionUrl = sessionData?.sessionUrl;
          final successUrl = sessionData?.successUrl;
          final cancelUrl = sessionData?.cancelUrl;

          if (sessionData == null ||
              sessionUrl == null ||
              sessionUrl.trim().isEmpty ||
              successUrl == null ||
              successUrl.trim().isEmpty ||
              cancelUrl == null ||
              cancelUrl.trim().isEmpty) {
            return ErrorResponse<OrderPlacementEntity>(
              error: 'Failed to initiate card payment: Missing payment session URLs.',
            );
          }
        }

        return SuccessResponse<OrderPlacementEntity>(
          OrderPlacementEntity(
            isSuccess: response.data.isSuccess,
            cardSession: sessionData?.toEntity(),
          ),
        );

      case ErrorResponse<PlaceOrderResponse>():
        return ErrorResponse<OrderPlacementEntity>(
          error: response.error,
        );
    }
  }
}