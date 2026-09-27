
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

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    id: json['_id'] ?? json['id'] ?? '',
    productName: json['productName'] ?? '',
    description: json['description'] ?? '',
    price: json['price'] ?? 0,
    quantity: json['quantity'] ?? 1,
    imageUrl: json['imageUrl'],
  );

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

