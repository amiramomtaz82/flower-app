// lib/features/checkout/presentation/cubit/checkout_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../../config/base_response/base_response.dart';
import '../../../../../config/resource/rsource.dart';
import '../../domain/entities/checkout_details_entity.dart';
import '../../domain/entities/estimated_delivery_entity.dart';


import '../../domain/usecases/estimated_delivery_usecase.dart';
import '../../domain/usecases/get_checkout_details_usecase.dart';
import '../../domain/usecases/place_order_usecase.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

@LazySingleton()
class CheckoutCubit extends Cubit<CheckoutState> {
  final GetCheckoutDetailsUseCase _getCheckoutDetailsUseCase;
  final EstimateDeliveryUseCase _estimateDeliveryUseCase;
  final PlaceOrderUseCase _placeOrderUseCase;


  CheckoutCubit(
      this._getCheckoutDetailsUseCase,
      this._estimateDeliveryUseCase,
      this._placeOrderUseCase,
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
        emit(
          state.copyWith(
            checkoutDetailsResource: Resource.success(details),
            selectedAddressId: defaultAddressId,
          ),
        );

        if (defaultAddressId != null) {
          await _estimateDelivery(defaultAddressId, cartId);
        }

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
        // If cash, disable and clear gift fields automatically
        isGift: isCash ? false : state.isGift,
        recipientName: isCash ? null : state.recipientName,
        recipientPhone: isCash ? null : state.recipientPhone,
      ),
    );
  }



  void _toggleGift(bool isGift) {
    // Prevent enabling gift if current payment method is cash
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

  Future<void> _placeOrder(String cartId) async {
    if (state.selectedAddressId == null || state.selectedAddressId!.isEmpty) {
      emit(state.copyWith(
        placeOrderResource: Resource.error('Please select a delivery address.'),
      ));
      return;
    }

    if (state.isGift && state.paymentMethod != PaymentMethodType.cash) {
      final name = state.recipientName?.trim() ?? '';
      final phone = state.recipientPhone?.trim() ?? '';

      if (name.isEmpty || phone.isEmpty) {
        emit(state.copyWith(
          placeOrderResource: Resource.error('Please provide recipient name and phone number for gifts.'),
        ));
        return;
      }
    }

    // Proceed with API call...
  }

  void _resetPlaceOrderState() {
    emit(
      state.copyWith(
        placeOrderResource: Resource.initial(),
      ),
    );
  }
}