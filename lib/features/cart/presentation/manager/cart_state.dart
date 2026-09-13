import 'package:equatable/equatable.dart';

import '../../../../config/resource/rsource.dart';
import '../../domain/entities/cart_entity.dart';

class CartState extends Equatable {
  final Resource<CartEntity> cartResource;

  // id of the row being changed right now
  final String? mutatingId;

  CartState({Resource<CartEntity>? cartResource, this.mutatingId})
    : cartResource = cartResource ?? Resource.initial();

  factory CartState.initial() {
    return CartState(cartResource: Resource.initial());
  }

  CartEntity? get cart => cartResource.data;

  bool get isEmpty => cartResource.data?.isEmpty ?? true;

  int get itemsCount => cartResource.data?.itemsCount ?? 0;

  bool isMutating(String id) => mutatingId == id;

  bool containsProduct(String? productId) => cartItemIdFor(productId) != null;

  String? cartItemIdFor(String? productId) {
    if (productId == null) return null;

    final items = cartResource.data?.items;
    if (items == null) return null;

    for (final item in items) {
      if (item.productId == productId) return item.id;
    }

    return null;
  }

  CartState copyWith({
    Resource<CartEntity>? cartResource,
    String? mutatingId,
    bool clearMutatingId = false,
  }) {
    return CartState(
      cartResource: cartResource ?? this.cartResource,
      mutatingId: clearMutatingId ? null : (mutatingId ?? this.mutatingId),
    );
  }

  @override
  List<Object?> get props => [cartResource, mutatingId];
}
