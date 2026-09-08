// lib/features/checkout/presentation/cubit/checkout_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../config/base_response/base_response.dart';
import '../../../../../config/resource/rsource.dart';
import '../../../../core/validation/validation.dart';
import '../../../Address/domain/use_cases/get_saved_address_useacse.dart';
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
      this._getSavedAddressesUseCase
      ) : super(CheckoutState.initial());

  Future<void> doEvents(CheckoutEvent event) async {
    switch (event) {
      case GetCheckoutDetailsEvent():
        await _getCheckoutDetails(event.cartId, event.defaultAddressId);

      case EstimateDeliveryEvent():
        await _estimateDelivery(event.addressId, event.cartId);

      case SelectPaymentMethodEvent():
        _selectPaymentMethod(event.paymentMethod);

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
        final details = result.data;

        // Populate initial delivery estimate directly from checkout details
        final initialDeliveryEstimate = EstimateDeliveryEntity(
          addressId: details.addressId ?? defaultAddressId ?? '',
          isServiceable: details.isServiceable,
          deliveryFee: details.deliveryFee,
          estimatedDeliveryAt: details.estimatedDeliveryAt,
        );

        emit(
          state.copyWith(
            checkoutDetailsResource: Resource.success(details),
            selectedAddressId: defaultAddressId ?? details.addressId,
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

  void _selectPaymentMethod(PaymentMethodType paymentMethod) {
    final isCash = paymentMethod == PaymentMethodType.cash;

    emit(
      state.copyWith(
        paymentMethod: paymentMethod,
        isGift: isCash ? false : state.isGift,
        recipientName: isCash ? null : state.recipientName,
        recipientPhone: isCash ? null : state.recipientPhone,
      ),
    );
  }

  void _toggleGift(bool isGift) {
    if (state.paymentMethod == PaymentMethodType.cash) return;

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

  // lib/features/checkout/presentation/cubit/checkout_cubit.dart

  Future<void> _placeOrder(String cartId) async {
    // 1. Validate Cart ID
    if (cartId.trim().isEmpty) {
      emit(state.copyWith(
        placeOrderResource: Resource.error('Cart identifier is missing.'),
      ));
      return;
    }

    // 2. Validate Address
    final addressId = state.selectedAddressId?.trim();
    if (addressId == null || addressId.isEmpty) {
      emit(state.copyWith(
        placeOrderResource: Resource.error('Please select a delivery address.'),
      ));
      return;
    }

    // 3. Validate Gift Fields (only applicable when gift is toggled ON and not cash)
    final isGiftActive = state.isGift && state.paymentMethod != PaymentMethodType.cash;
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
    // 4. Emit Loading
    emit(state.copyWith(
      placeOrderResource: Resource.loading(),
    ));

    // 5. Build Complete PlaceOrderRequestEntity
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
      paymentMethod: state.paymentMethod == PaymentMethodType.cash ? 'COD' : 'Card',
      paymentGateway: state.paymentMethod == PaymentMethodType.card ? 'Paymob' : null,
    );

    // 6. Execute Use Case & Handle Response
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