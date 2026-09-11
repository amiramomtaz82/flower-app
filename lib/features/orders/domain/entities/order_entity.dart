import 'package:equatable/equatable.dart';

enum OrderStatus { active, completed }

class OrderEntity extends Equatable {
  const OrderEntity({
    required this.id,
    required this.productName,
    required this.imageUrl,
    required this.currency,
    required this.price,
    required this.status,
    this.orderNumber,
    this.deliveredOn,
  });

  final String id;
  final String productName;
  final String imageUrl;
  final String currency;
  final num price;
  final OrderStatus status;
  final String? orderNumber;
  final String? deliveredOn;

  @override
  List<Object?> get props => [
        id,
        productName,
        imageUrl,
        currency,
        price,
        status,
        orderNumber,
        deliveredOn,
      ];
}
