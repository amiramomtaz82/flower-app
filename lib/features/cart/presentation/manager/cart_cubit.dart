import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../../../../config/resource/rsource.dart';
import '../../../../core/app_constants/app_strings.dart';
import '../../../../core/ui_action/ui_action.dart';
import '../../../../core/ui_action/ui_action_dispatcher.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/use_cases/add_to_cart_use_case.dart';
import '../../domain/use_cases/get_cart_use_case.dart';
import '../../domain/use_cases/remove_cart_item_use_case.dart';
import '../../domain/use_cases/update_cart_item_quantity_use_case.dart';
import 'cart_events.dart';
import 'cart_state.dart';

@injectable
class CartCubit extends Cubit<CartState> {
  final GetCartUseCase _getCartUseCase;
  final AddToCartUseCase _addToCartUseCase;
  final UpdateCartItemQuantityUseCase _updateCartItemQuantityUseCase;
  final RemoveCartItemUseCase _removeCartItemUseCase;
  final UiActionDispatcher _uiActionDispatcher;

  CartCubit(
    this._getCartUseCase,
    this._addToCartUseCase,
    this._updateCartItemQuantityUseCase,
    this._removeCartItemUseCase,
    this._uiActionDispatcher,
  ) : super(CartState.initial());

  Future<void> doEvents(CartEvent event) async {
    switch (event) {
      case CartLoaded():
        await _loadCart();

      case CartItemAdded():
        await _addItem(event);

      case CartItemQuantityChanged():
        await _changeQuantity(event);

      case CartItemRemoved():
        await _removeItem(event);
    }
  }

  Future<void> _loadCart() async {
    emit(state.copyWith(cartResource: Resource.loading()));

    final result = await _getCartUseCase();

    switch (result) {
      case SuccessResponse<CartEntity>():
        emit(state.copyWith(cartResource: Resource.success(result.data)));

      case ErrorResponse<CartEntity>():
        emit(state.copyWith(cartResource: Resource.error(result.errMessage)));
    }
  }

  Future<void> _addItem(CartItemAdded event) async {
    _startMutation(event.productId);

    final result = await _addToCartUseCase(
      productId: event.productId,
      quantity: event.quantity,
    );

    _endMutation(result, successMessage: AppStrings.productAddedToCart);
  }

  Future<void> _changeQuantity(CartItemQuantityChanged event) async {
    _startMutation(event.productId);

    final result = await _updateCartItemQuantityUseCase(
      productId: event.productId,
      quantity: event.quantity,
    );

    _endMutation(result);
  }

  Future<void> _removeItem(CartItemRemoved event) async {
    _startMutation(event.cartItemId);

    final result = await _removeCartItemUseCase(cartItemId: event.cartItemId);

    _endMutation(result, successMessage: AppStrings.productRemovedFromCart);
  }

  void _startMutation(String id) {
    emit(state.copyWith(mutatingId: id));
  }

  void _endMutation(
    BaseResponse<CartEntity> result, {
    String? successMessage,
  }) {
    switch (result) {
      case SuccessResponse<CartEntity>():
        emit(
          state.copyWith(
            cartResource: Resource.success(result.data),
            clearMutatingId: true,
          ),
        );
        if (successMessage != null) {
          _uiActionDispatcher.dispatch(
            ShowSnackBarAction.success(successMessage),
          );
        }

      case ErrorResponse<CartEntity>():
        emit(state.copyWith(clearMutatingId: true));
        _uiActionDispatcher.dispatch(
          ShowSnackBarAction.error(result.errMessage),
        );
    }
  }
}
