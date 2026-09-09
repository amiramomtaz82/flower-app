import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/cart_entity.dart';
import 'cart_item_dto.dart';

part 'cart_dto.g.dart';

@JsonSerializable()
class CartDto {
  final String? id;
  final String? customerId;
  final List<CartItemDto>? items;
  final num? subtotal;
  final num? deliveryFee;
  final num? total;
  final bool? hasChanges;

  const CartDto({
    this.id,
    this.customerId,
    this.items,
    this.subtotal,
    this.deliveryFee,
    this.total,
    this.hasChanges,
  });

  factory CartDto.fromJson(Map<String, dynamic> json) =>
      _$CartDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CartDtoToJson(this);

  CartEntity toEntity() {
    return CartEntity(
      id: id,
      customerId: customerId,
      items: items?.map((item) => item.toEntity()).toList() ?? const [],
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      hasChanges: hasChanges ?? false,
    );
  }
}
