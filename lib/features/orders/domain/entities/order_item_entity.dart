import 'package:equatable/equatable.dart';


class OrderItemEntity extends Equatable {
  final String id;
  final String productName;
  final String description; // '18 Pink Rose Bouquet'
  final num price;
  final int quantity;
  final String? imageUrl;
  const OrderItemEntity({
    required this.id,
    required this.productName,
    required this.description,
    required this.price,
    this.quantity = 1,
    this.imageUrl,
  });
  @override
  List<Object?> get props => [id, productName, description, price, quantity, imageUrl];
}