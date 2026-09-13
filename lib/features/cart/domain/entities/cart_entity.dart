import 'package:equatable/equatable.dart';

import 'cart_item_entity.dart';

class CartEntity extends Equatable {
  final String? id;
  final String? customerId;
  final List<CartItemEntity> items;
  final num? subtotal;
  final num? deliveryFee;
  final num? total;

  final bool hasChanges;

  const CartEntity({
    this.id,
    this.customerId,
    this.items = const [],
    this.subtotal,
    this.deliveryFee,
    this.total,
    this.hasChanges = false,
  });

  bool get isEmpty => items.isEmpty;

  int get itemsCount =>
      items.fold(0, (count, item) => count + (item.quantity ?? 0));

  @override
  List<Object?> get props => [
    id,
    customerId,
    items,
    subtotal,
    deliveryFee,
    total,
    hasChanges,
  ];
}
