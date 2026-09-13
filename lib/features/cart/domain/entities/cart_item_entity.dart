import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String? id;
  final String? productId;
  final String? productName;
  final String? productImageUrl;
  final num? unitPrice;
  final int? quantity;
  final num? lineSubtotal;
  final bool inStock;
  final int? availableStock;

  /// Only reported by `GET /cart`, which re-checks prices at read time.
  final bool priceChanged;

  const CartItemEntity({
    this.id,
    this.productId,
    this.productName,
    this.productImageUrl,
    this.unitPrice,
    this.quantity,
    this.lineSubtotal,
    this.inStock = true,
    this.availableStock,
    this.priceChanged = false,
  });

  @override
  List<Object?> get props => [
    id,
    productId,
    productName,
    productImageUrl,
    unitPrice,
    quantity,
    lineSubtotal,
    inStock,
    availableStock,
    priceChanged,
  ];
}
