import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/cart_item_entity.dart';

part 'cart_item_dto.g.dart';

/// Absorbs both shapes the Cart API returns for a line item:
/// `GetCartItemResponse` (from `GET /cart`) and `CartItemSummaryDto` (from the
/// write endpoints). Every field is nullable because each shape omits some of
/// the other's — `priceChanged` is GET-only.
@JsonSerializable()
class CartItemDto {
  final String? id;
  final String? productId;
  final String? productName;
  final String? productImageUrl;
  final num? unitPrice;
  final int? quantity;
  final num? lineSubtotal;
  final bool? inStock;
  final int? availableStock;
  final bool? priceChanged;

  const CartItemDto({
    this.id,
    this.productId,
    this.productName,
    this.productImageUrl,
    this.unitPrice,
    this.quantity,
    this.lineSubtotal,
    this.inStock,
    this.availableStock,
    this.priceChanged,
  });

  factory CartItemDto.fromJson(Map<String, dynamic> json) =>
      _$CartItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemDtoToJson(this);

  CartItemEntity toEntity() {
    return CartItemEntity(
      id: id,
      productId: productId,
      productName: productName,
      productImageUrl: productImageUrl,
      unitPrice: unitPrice,
      quantity: quantity,
      lineSubtotal: lineSubtotal,
      inStock: inStock ?? true,
      availableStock: availableStock,
      priceChanged: priceChanged ?? false,
    );
  }
}
