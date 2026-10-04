
import '../../domain/entities/order_item_entity.dart';

class OrderItemModel {
  final String id;
  final String productName;
  final String description;
  final num price;
  final int quantity;
  final String? imageUrl;

  const OrderItemModel({
    required this.id,
    required this.productName,
    required this.description,
    required this.price,
    this.quantity = 1,
    this.imageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final productMap = json['product'] is Map ? json['product'] as Map : null;
    final id = json['_id']?.toString() ??
        json['id']?.toString() ??
        json['productId']?.toString() ??
        productMap?['_id']?.toString() ??
        productMap?['id']?.toString() ??
        '';
    final name = json['productName']?.toString() ??
        json['name']?.toString() ??
        json['title']?.toString() ??
        productMap?['productName']?.toString() ??
        productMap?['title']?.toString() ??
        productMap?['name']?.toString() ??
        'Product';
    final desc = json['description']?.toString() ??
        productMap?['description']?.toString() ??
        '';
    final price = (json['price'] as num?) ??
        (json['unitPrice'] as num?) ??
        (productMap?['price'] as num?) ??
        0;
    final qty = (json['quantity'] as num?)?.toInt() ??
        (json['count'] as num?)?.toInt() ??
        1;
    final image = json['imageUrl']?.toString() ??
        json['image']?.toString() ??
        productMap?['imageUrl']?.toString() ??
        productMap?['image']?.toString();

    return OrderItemModel(
      id: id,
      productName: name,
      description: desc,
      price: price,
      quantity: qty,
      imageUrl: image,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'productName': productName,
    'description': description,
    'price': price,
    'quantity': quantity,
    'imageUrl': imageUrl,
  };

  OrderItemEntity toEntity() => OrderItemEntity(
    id: id,
    productName: productName,
    description: description,
    price: price,
    quantity: quantity,
    imageUrl: imageUrl,
  );
}

