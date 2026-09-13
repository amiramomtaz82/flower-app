sealed class CartEvent {}

class CartLoaded extends CartEvent {}

class CartItemAdded extends CartEvent {
  final String productId;
  final int quantity;

  CartItemAdded({required this.productId, this.quantity = 1});
}

// quantity 0 removes the line
class CartItemQuantityChanged extends CartEvent {
  final String productId;
  final int quantity;

  CartItemQuantityChanged({required this.productId, required this.quantity});
}

class CartItemRemoved extends CartEvent {
  final String cartItemId;

  CartItemRemoved(this.cartItemId);
}
