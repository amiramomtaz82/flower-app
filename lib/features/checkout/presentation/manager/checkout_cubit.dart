import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../config/base_response/base_response.dart';
import '../../../../../config/resource/rsource.dart';
import '../../../../core/validation/validation.dart';

import '../../../Address/domain/use_cases/get_saved_address_use_case.dart';
import '../../domain/entities/checkout_details_entity.dart';
import '../../domain/entities/estimated_delivery_entity.dart';
import '../../domain/entities/gift_recipient_entity.dart';
import '../../domain/entities/oder_placment_entity.dart';
import '../../domain/entities/place_order_request_entity.dart';
import '../../domain/usecases/estimated_delivery_usecase.dart';
import '../../domain/usecases/get_checkout_details_usecase.dart';
import '../../domain/usecases/place_order_usecase.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

@injectable
class CheckoutCubit extends Cubit<CheckoutState> {
  final GetCheckoutDetailsUseCase _getCheckoutDetailsUseCase;
  final EstimateDeliveryUseCase _estimateDeliveryUseCase;
  final PlaceOrderUseCase _placeOrderUseCase;
  final GetSavedAddressesUseCase _getSavedAddressesUseCase;

  CheckoutCubit(
      this._getCheckoutDetailsUseCase,
      this._estimateDeliveryUseCase,
      this._placeOrderUseCase,
      this._getSavedAddressesUseCase,
      ) : super(CheckoutState.initial());

  Future<void> doEvents(CheckoutEvent event) async {
    switch (event) {
      case GetCheckoutDetailsEvent():
        await _getCheckoutDetails(event.cartId, event.defaultAddressId);

      case EstimateDeliveryEvent():
        await _estimateDelivery(event.addressId, event.cartId);

      case SelectPaymentMethodEvent():
        _selectPaymentMethod(event.method, event.gateway);

      case ToggleGiftEvent():
        _toggleGift(event.isGift);

      case UpdateGiftDetailsEvent():
        _updateGiftDetails(event.name, event.phone);

      case PlaceOrderEvent():
        await _placeOrder(event.cartId);

      case ResetPlaceOrderStateEvent():
        _resetPlaceOrderState();
    }
  }
// ============================================================
// GET CHECKOUT DETAILS
// ============================================================

  Future<void> _getCheckoutDetails(String cartId, String? defaultAddressId) async {
    emit(
      state.copyWith(
        checkoutDetailsResource: Resource.loading(),
      ),
    );

    final result = await _getCheckoutDetailsUseCase(cartId);

    switch (result) {
      case SuccessResponse<CheckoutDetailsEntity>():
        final checkoutDetails = result.data;

        // Populate initial delivery estimate directly from checkout details
        final initialDeliveryEstimate = EstimateDeliveryEntity(
          addressId: defaultAddressId ?? '',
          isServiceable: true,
          deliveryFee: checkoutDetails.deliveryFee,
          estimatedDeliveryAt: checkoutDetails.estimatedDeliveryAt,
        );

        // 1. Resolve available payment methods from the API response
        final availableMethods = checkoutDetails.paymentMethods;
        final defaultMethod = state.selectedPaymentMethod ??
            (availableMethods.isNotEmpty ? availableMethods.first.method : null);

        final cardOption = availableMethods.firstWhereOrNull(
              (m) => m.method.toUpperCase() == 'CARD',
        );

        final defaultGateway = defaultMethod?.toUpperCase() == 'CARD'
            ? cardOption?.gateways.firstOrNull
            : null;

        emit(
          state.copyWith(
            checkoutDetailsResource: Resource.success(checkoutDetails),
            selectedAddressId: defaultAddressId,
            selectedPaymentMethod: defaultMethod,
            selectedPaymentGateway: defaultGateway,
            estimateDeliveryResource: Resource.success(initialDeliveryEstimate),
          ),
        );

      case ErrorResponse<CheckoutDetailsEntity>():
        emit(
          state.copyWith(
            checkoutDetailsResource: Resource.error(result.errMessage),
          ),
        );
    }
  }
  // ============================================================
  // ESTIMATE DELIVERY
  // ============================================================

  Future<void> _estimateDelivery(String addressId, String cartId) async {
    emit(
      state.copyWith(
        selectedAddressId: addressId,
        estimateDeliveryResource: Resource.loading(),
      ),
    );

    final result = await _estimateDeliveryUseCase(
      addressId: addressId,
      cartId: cartId,
    );

    switch (result) {
      case SuccessResponse<EstimateDeliveryEntity>():
        emit(
          state.copyWith(
            estimateDeliveryResource: Resource.success(result.data),
          ),
        );

      case ErrorResponse<EstimateDeliveryEntity>():
        emit(
          state.copyWith(
            estimateDeliveryResource: Resource.error(result.errMessage),
          ),
        );
    }
  }

  // ============================================================
  // FORM & SELECTION ACTIONS
  // ============================================================

  // 2. Select Payment Method & Gateway
  void _selectPaymentMethod(String method, String? gateway) {
    final isCash = method.toUpperCase() == 'COD';

    emit(
      state.copyWith(
        selectedPaymentMethod: method,
        selectedPaymentGateway: gateway,
        clearPaymentGateway: isCash || gateway == null, // <--- Clears gateway when null or COD
        isGift: isCash ? false : state.isGift,
        clearRecipient: isCash,
      ),
    );
  }
  void _toggleGift(bool isGift) {
    if (state.selectedPaymentMethod?.toUpperCase() == 'COD') return;

    emit(state.copyWith(isGift: isGift));
  }

  void _updateGiftDetails(String? name, String? phone) {
    emit(
      state.copyWith(
        recipientName: name ?? state.recipientName,
        recipientPhone: phone ?? state.recipientPhone,
      ),
    );
  }

  // ============================================================
  // PLACE ORDER
  // ============================================================

  Future<void> _placeOrder(String cartId) async {
    if (cartId.trim().isEmpty) {
      emit(state.copyWith(
        placeOrderResource: Resource.error('Cart identifier is missing.'),
      ));
      return;
    }

    final addressId = state.selectedAddressId?.trim();
    if (addressId == null || addressId.isEmpty) {
      emit(state.copyWith(
        placeOrderResource: Resource.error('Please select a delivery address.'),
      ));
      return;
    }

    final paymentMethod = state.selectedPaymentMethod?.trim();
    if (paymentMethod == null || paymentMethod.isEmpty) {
      emit(state.copyWith(
        placeOrderResource: Resource.error('Please select a payment method.'),
      ));
      return;
    }

    final isGiftActive = state.isGift && paymentMethod.toUpperCase() != 'COD';
    final recipientName = state.recipientName?.trim() ?? '';
    final recipientPhone = state.recipientPhone?.trim() ?? '';

    if (isGiftActive) {
      final nameError = Validation.validateName(recipientName);
      if (nameError != null) {
        emit(state.copyWith(
          placeOrderResource: Resource.error(nameError),
        ));
        return;
      }

      final phoneError = Validation.validatePhoneNumber(recipientPhone);
      if (phoneError != null) {
        emit(state.copyWith(
          placeOrderResource: Resource.error(phoneError),
        ));
        return;
      }
    }

    emit(state.copyWith(
      placeOrderResource: Resource.loading(),
    ));

    final orderRequest = PlaceOrderRequestEntity(
      cartId: cartId.trim(),
      addressId: addressId,
      isGift: isGiftActive,
      giftRecipient: isGiftActive
          ? GiftRecipientEntity(
        name: recipientName,
        phone: recipientPhone,
      )
          : null,
      paymentMethod: paymentMethod,
      paymentGateway: state.selectedPaymentGateway,
    );

    final result = await _placeOrderUseCase(orderRequest);

    switch (result) {
      case SuccessResponse<OrderPlacementEntity>():
        emit(state.copyWith(
          placeOrderResource: Resource.success(result.data),
        ));
      case ErrorResponse<OrderPlacementEntity>():
        emit(state.copyWith(
          placeOrderResource: Resource.error(result.errMessage),
        ));
    }
  }

  void _resetPlaceOrderState() {
    emit(
      state.copyWith(
        placeOrderResource: Resource.initial(),
      ),
    );
  }
}